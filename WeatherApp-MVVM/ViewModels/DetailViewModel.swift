//
//  DetailViewModel.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/12.
//

import Foundation
import RxSwift
import RxCocoa
import Charts
import DGCharts
import CoreLocation
import Alamofire

class DetailViewModel {
    
    public var selectedPrefecture = BehaviorSubject<String>(value: "Loading")
    private var selectedPrefectureString: String?
    private var currentLocation: CLLocation?
    
    public let weatherData = PublishRelay<[SectionWeatherData]>()
    public let chartData = PublishRelay<LineChartData>()
    public let chartFormatter = PublishRelay<IndexAxisValueFormatter>()
    private var popArray: [Double] = []
    private var timeArray: [String] = []
    public var todayDate = BehaviorSubject<String>(value: "")
    
    let isLoading = BehaviorRelay(value: false)
    var isLoadingDriver: Driver<Bool> {
        isLoading.asDriver()
    }
    public var APIErrorMessage = PublishRelay<String>()
    
    private let weatherModel: WeatherAPIProtcol
    private let disposeBag = DisposeBag()
    
    init(prefecture: String? = nil, location: CLLocation? = nil) {
        weatherModel = APICaller()
        selectedPrefectureString = prefecture
        currentLocation = location
        todayDate.onNext(getTodayDate()) //今日の日付を取得してtodayDateに通知しておく
        // weatherDataが更新されたタイミングでChart用のデータを更新
        weatherData
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateChartsData()
            })
            .disposed(by: disposeBag)
    }
    
    public func fetch() {
        isLoading.accept(true) // indicatorを開始
        // prefectureが渡されているか、初期化時にlocationが渡されているかで条件分岐
        let weatherDataSingle: Single<WeatherData>
        if let prefecture = selectedPrefectureString {
            let request = weatherModel.setupRequest(prefecture: prefecture, model: WeatherRequestModel())
            weatherDataSingle = self.weatherModel.fetchWeatherData(request: request)
        } else if let location = currentLocation {
            let request = weatherModel.setupRequest(location: location, model: WeatherRequestModel())
            weatherDataSingle = self.weatherModel.fetchWeatherData(request: request)
        } else {
            weatherDataSingle = Single.error(APIError.parameterUnSet("現在地も都道府県もセットされていません"))
        }
        weatherDataSingle // API通信の結果がSingle<WeatherData>で返ってくる
            .flatMap { data -> Single<[DisplayWeatherData]> in // flatmapで流れてきたWeatherDataを変化させる
                self.selectedPrefecture.onNext(data.city.name) //　都市名の表示を反映
                let observable = Observable.from(data.list) // Observableを作る([ThreeHourlyWeather])
                return observable
                    .do(onNext: { threeHourlyWeather in // charts用に時間とpopデータを配列に追加
                        self.popArray.append(threeHourlyWeather.pop * 100)
                        self.timeArray.append(threeHourlyWeather.dt.changeTimeString())
                    })
                        .concatMap { threeHourlyWeather in // concatMapにして配列の順番通りに処理する
                            self.changeDisplayData(threeHourlyWeather: threeHourlyWeather) // Single<DisplayWeatherData>で返ってくるが、concatMapでObservable<DisplayWeatherData>にまとめられる
                        }
                        .toArray() //配列に戻す(.toArrayはSingleで返る)
            }
            .subscribe(onSuccess: { displayData in // ここでの結果はfetchWeatherDataのsuccessかfailureが返ってくるためエラー分岐できる
                let sectionData = self.changeToSectionWeatherData(weatherData: displayData) // SectionWeatherDataに変換処理
                self.weatherData.accept(sectionData)
                self.isLoading.accept(false) //indicatorを停止
            }, onFailure: { error in
                self.isLoading.accept(false) //エラーの場合もindicatorを停止
                self.errorHandling(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    private func getTodayDate() -> String {
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日"
        return dateFormatter.string(from: dt)
    }
    
    // 受け取ったDisplayWeatherDataの配列をセクションデータの配列に変換
    private func changeToSectionWeatherData(weatherData: [DisplayWeatherData]) -> [SectionWeatherData] {
        return weatherData.reduce(into: [SectionWeatherData]()) { result, weatherData in
            if let index = result.firstIndex(where: { $0.header == weatherData.date }) {
                result[index].items.append(weatherData)
            } else {
                let newSection = SectionWeatherData(header: weatherData.date, items: [weatherData])
                result.append(newSection)
            }
        }
    }
    
    // 3時間ごとの天気情報をUI表示用に変換
    // iconDataはfetchWeatherIconをしてAPI取得
    private func changeDisplayData(threeHourlyWeather: ThreeHourlyWeather) -> Single<DisplayWeatherData> {
        let date = threeHourlyWeather.dt.changeDateString()
        let time = threeHourlyWeather.dt.changeTimeString()
        let maxTemparture = String(format: "%.1f", threeHourlyWeather.main.temp_max)
        let minTemparture = String(format: "%.1f", threeHourlyWeather.main.temp_min)
        let humidit = String(threeHourlyWeather.main.humidity)
        let iconName = threeHourlyWeather.weather.first?.icon ?? ""
        
        return weatherModel.fetchWeatherIcon(iconName: iconName) // Single<Data>で返ってくる
            .map { iconData in
                DisplayWeatherData(date: date, time: time, iconData: iconData ?? Data(), maxTemparture: maxTemparture, minTemparture: minTemparture, humidity: humidit)
            }
    }
    
    private func errorHandling(error: Error) {
        if let afError = error as? AFError {
            switch afError {
                // Sessionエラーを検知
            case .sessionTaskFailed(error: let sessionError):
                if let urlError = sessionError as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        self.APIErrorMessage.accept("ネットワークに接続できませんでした")
                    case .timedOut:
                        self.APIErrorMessage.accept("タイムアウトしました")
                    default :
                        self.APIErrorMessage.accept("URLError　Other Error: \(urlError.localizedDescription)")
                    }
                } else {
                    self.APIErrorMessage.accept("SessionTaskFailed　Other Error: \(sessionError)")
                }
                // status codeが200番台以外を検知
            case .responseValidationFailed(reason: let reason):
                switch reason {
                case .unacceptableStatusCode(code: let code):
                    if code >= 400 && code < 600 {
                        self.APIErrorMessage.accept("データの取得に失敗しました")
                    }
                default :
                    self.APIErrorMessage.accept("Response Validation Other Error")
                }
                // レスポンスエラー(主にデコードエラーを検知)
            case .responseSerializationFailed(reason: let reason) :
                switch reason {
                case .decodingFailed:
                    self.APIErrorMessage.accept("デコードに失敗しました")
                default:
                    self.APIErrorMessage.accept("Response Other Error")
                }
            default :
                self.APIErrorMessage.accept("Other AFError: \(afError)")
            }
        }
        else if let apiError = error as? APIError {
            switch apiError {
            case .nilData:
                self.APIErrorMessage.accept("データの取得に失敗しました")
            case .parameterUnSet(let error):
                self.APIErrorMessage.accept("\(error)")
            }
        }
        else {
            self.APIErrorMessage.accept("Other Error: \(error)")
        }
    }
    
    private func updateChartsData() {
        var dataEntries: [ChartDataEntry] = []
        for (index, pop) in self.popArray.enumerated() {
            let entry = ChartDataEntry(x: Double(index), y: pop)
            dataEntries.append(entry)
        }
        let dataSet = LineChartDataSet(entries: dataEntries, label: "")
        let chartData = LineChartData(dataSet: dataSet)
        self.chartData.accept(chartData)
        let formatter = IndexAxisValueFormatter(values: self.timeArray)
        self.chartFormatter.accept(formatter)
    }
}

enum APIError: Error {
    case nilData
    case parameterUnSet(String)
}

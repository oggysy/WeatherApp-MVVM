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
    
    var selectedPrefecture = BehaviorSubject<String>(value: "")
    var currentLocation: CLLocation?
    
    private let weatherData = BehaviorRelay<[SectionWeatherData]>(value: [])
    var weatherDataDriver: Driver<[SectionWeatherData]> {
        weatherData.asDriver()
    }
    private let chartData = PublishRelay<LineChartData>()
    var chartDataDriver: Driver<LineChartData> {
        chartData.asDriver(onErrorJustReturn: LineChartData())
    }
    private let chartFormatter = PublishRelay<IndexAxisValueFormatter>()
    var chartFormatterDriver: Driver<IndexAxisValueFormatter> {
        chartFormatter.asDriver(onErrorJustReturn: IndexAxisValueFormatter())
    }
    private var popArray: [Double] = []
    private var timeArray: [String] = []
    private var todayDate = BehaviorSubject<String>(value: "")
    var todayDateDriver: Driver<String> {
        todayDate.asDriver(onErrorJustReturn: "")
    }
    
    let isLoading = BehaviorRelay(value: false)
    var isLoadingDriver: Driver<Bool> {
        isLoading.asDriver()
    }
    private var APIErrorMessage = PublishRelay<String>()
    var APIErrorMessageDriver: Driver<String> {
        return APIErrorMessage.asDriver(onErrorJustReturn: "")
    }
    
    let fetchDataTrigger = PublishSubject<Void>()
    private let weatherModel: WeatherAPIProtcol
    private let disposeBag = DisposeBag()
    
    init(prefecture: String? = nil, location: CLLocation? = nil) {
        isLoading.accept(true) // indicatorを開始
        weatherModel = APICaller()
        fetchDataTrigger.subscribe(onDisposed: { [weak self] in
            guard let self = self else {
                self?.isLoading.accept(false)
                return
            }
            todayDate.onNext(getTodayDate()) //今日の日付を取得してtodayDateに通知しておく
            // prefectureが渡されているか、初期化時にlocationが渡されているかで条件分岐
            let weatherDataSingle: Single<WeatherData>
            if let prefecture = prefecture {
                let request = weatherModel.setupRequest(prefecture: prefecture, model: WeatherRequestModel())
                weatherDataSingle = self.weatherModel.fetchWeatherData(request: request)
            } else if let location = location {
                let request = weatherModel.setupRequest(location: location, model: WeatherRequestModel())
                weatherDataSingle = self.weatherModel.fetchWeatherData(request: request)
            } else {
                weatherDataSingle = Single.error(ParameterError.parameterUnSet("現在地も都道府県もセットされていません"))
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
                            self.changeDisplayData(threeHourlyWeather: threeHourlyWeather) // DisplayDataに変換　返り値はSingle<DisplayWeatherData>(IconDataをAPI通信で取得しているため)
                        }
                        .toArray() //配列に戻す
                }
                .subscribe(onSuccess: { displayData in // ここでの結果はfetchWeatherDataのsuccessかfailureが返ってくるためエラー分岐できる
                    let sectionData = self.changeToSectionWeatherData(weatherData: displayData) // SectionWeatherDataに変換処理
                    self.weatherData.accept(sectionData)
                    self.isLoading.accept(false) //indicatorを停止
                }, onFailure: { error in
                    self.isLoading.accept(false) //エラーの場合もindicatorを停止
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
                                    print("SessionError　Other Error")
                                }
                            } else {
                                print("SessionTaskFailed　Other Error")
                            }

                            // status codeが200番台以外を検知
                        case .responseValidationFailed(reason: let reason):
                            switch reason {
                            case .unacceptableStatusCode(code: let code):
                                if code >= 400 && code < 600 {
                                    self.APIErrorMessage.accept("データの取得に失敗しました")
                                }
                            default :
                                print("Response Validation Other Error")
                            }
                            
                            // レスポンスエラー(主にデコードエラーを検知)
                        case .responseSerializationFailed(reason: let reason) :
                            switch reason {
                            case .decodingFailed:
                                self.APIErrorMessage.accept("デコードに失敗しました")
                            default:
                                print("Response Other Error: \(error)")
                            }
                        default :
                            print("Other Error: \(error)")
                        }
                    }
                    else if let responceError = error as? ResponseError {
                        switch responceError {
                        case .nilData:
                            self.APIErrorMessage.accept("データの取得に失敗しました")
                        }
                    }
                    else {
                        print("不明なエラー\(error)")
                    }
                })
                .disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        // weatherDataが更新されたタイミングでChart用のデータを更新
        weatherData
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
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
    
}

enum ParameterError: Error {
    case parameterUnSet(String)
}

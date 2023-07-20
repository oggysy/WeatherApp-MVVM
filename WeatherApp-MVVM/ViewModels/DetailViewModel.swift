//
//  DetailViewModel.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/12.
//

import Foundation
import RxSwift
import RxCocoa

class DetailViewModel {
    
    var selectedPrefecture: BehaviorSubject<String>
    let weatherData = BehaviorRelay<[SectionWeatherData]>(value: [])
    var weatherDataDriver: Driver<[SectionWeatherData]> {
        weatherData.asDriver()
    }
    let fetchDataTrigger = PublishSubject<Void>()
    let weatherModel: WeatherAPIProtcol
    let disposeBag = DisposeBag()
    
    init(prefecture: String) {
        self.selectedPrefecture = BehaviorSubject(value: prefecture)
        weatherModel = APICaller()
        fetchDataTrigger.subscribe(onDisposed: { [weak self] in
            guard let self = self else { return }
            try? self.weatherModel.fetchWeatherData(at: self.selectedPrefecture.value()) // ここで返ってくるのはSingle<WeatherData>
                .flatMap { data -> Single<[DisplayWeatherData]> in // flatmapで流れてきたWeatherDataを変化させる
                    let observable = Observable.from(data.list) // Observableを作る([ThreeHourlyWeather])
                    return observable
                        .flatMap { threeHourlyWeather in // Observableをflatmap(配列一つ一つに処理するため)
                            self.convertDisplayData(threeHourlyWeather: threeHourlyWeather) // DisplayDataに変換　返り値はSingle<DisplayWeatherData>
                        }
                        .toArray() //配列に戻す
                }
                .subscribe(onSuccess: { displayData in
                    let sectionData = self.convertToSectionWeatherData(weatherData: displayData)
                    self.weatherData.accept(sectionData)
                }, onFailure: { error in
                    print(error)
                })
                .disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
    }
    
    // 受け取ったDisplayWeatherDataの配列をセクションデータの配列に変換
    func convertToSectionWeatherData(weatherData: [DisplayWeatherData]) -> [SectionWeatherData] {
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
    func convertDisplayData(threeHourlyWeather: ThreeHourlyWeather) -> Single<DisplayWeatherData> {
        let date = Date(timeIntervalSince1970: threeHourlyWeather.dt)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        let dateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "H:mm"
        let time = dateFormatter.string(from: date)
        let maxTemparture = String(format: "%.1f", threeHourlyWeather.main.temp_max)
        let minTemparture = String(format: "%.1f", threeHourlyWeather.main.temp_min)
        let humidit = String(threeHourlyWeather.main.humidity)
        let iconName = threeHourlyWeather.weather.first?.icon ?? ""
        let pop = threeHourlyWeather.pop
        return weatherModel.fetchWeatherIcon(iconName: iconName)
            .map { iconData in
                DisplayWeatherData(date: dateString, time: time, iconData: iconData, maxTemparture: maxTemparture, minTemparture: minTemparture, humidity: humidit, pop: pop)
            }
    }
}

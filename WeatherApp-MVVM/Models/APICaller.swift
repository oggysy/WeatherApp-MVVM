//
//  APICaller.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/13.
//

import Foundation
import RxCocoa
import RxSwift

protocol weatherAPIProtcol {
    func fetchWeatherData(at cityname: String) -> [SectionWeatherData]
}

class APICaller: weatherAPIProtcol {
    
    let testWetherData = [ SectionWeatherData(header: "7月13日", items: [
        WeatherData(date: "15:00", weather: "sunny", highestTemperature: 15.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "18:00", weather: "sunny", highestTemperature: 20.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "21:00", weather: "sunny", highestTemperature: 22.0, lowestTemperature: 20.0, humidity: 50),
    ]),
                           SectionWeatherData(header: "7月14日", items: [
                            WeatherData(date: "0:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50),
                            WeatherData(date: "3:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50),
                            WeatherData(date: "6:00", weather: "sunny", highestTemperature: 30.0, lowestTemperature: 20.0, humidity: 50),
                            WeatherData(date: "9:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50),
                            WeatherData(date: "12:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50)
                           ])
    ]
    
    
    func fetchWeatherData(at prefecture: String) -> [SectionWeatherData] {
        // いったんテストデータを返す処理にする
        return self.testWetherData
    }
}

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
//    func fetchWeatherData(at cityname: String) -> Observable<WeatherData>
}

class APICaller: weatherAPIProtcol {
    
    let testWetherData = [
        WeatherData(date: "0:00", weather: "sunny", highestTemperature: 15.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "3:00", weather: "sunny", highestTemperature: 20.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "6:00", weather: "sunny", highestTemperature: 22.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "9:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "12:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "15:00", weather: "sunny", highestTemperature: 30.0, lowestTemperature: 20.0, humidity: 50)
    ]
    
    
//    func fetchWeatherData(at prefecture: String) -> Observable<WeatherData> {
//        // いったんテストデータを返す処理にする
//        return Observable<WeatherData>()
//    }
}

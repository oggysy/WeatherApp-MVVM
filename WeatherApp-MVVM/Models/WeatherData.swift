//
//  WeatherData.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/07.
//

import Foundation
import RxDataSources

struct WeatherData: Decodable {
    let list: [ThreeHourlyWeather]
    let city: City
}

struct ThreeHourlyWeather: Decodable {
    let dt: TimeInterval
    let main: Main
    let weather: [Weather]
    let pop: Double
}

struct Main: Decodable {
    let temp_max: Double
    let temp_min: Double
    let humidity: Int
}

struct Weather: Decodable {
    let icon: String
}

struct City: Decodable {
    let name: String
}

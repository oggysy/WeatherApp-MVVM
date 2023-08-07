//
//  WedgetWeatherData.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/08/07.
//

import SwiftUI
import Foundation

struct WidgetWeatherData: Decodable {
    let weather: [WidgetWeather]
    let main: WidgetMain
    let wind:Wind
    let dt: TimeInterval
    let name: String
}

struct WidgetWeather: Decodable {
    let icon: String
}

struct WidgetMain: Decodable {
    let temp: Double
    let pressure: Int
    let humidity: Int
}

struct Wind: Decodable {
    let speed: Double
}

// サンプル表示用のオブジェクト
let widgetWeather = [WidgetWeather(icon: "000")]
let widgetMain = WidgetMain(temp: 30, pressure: 1000, humidity: 55)
let widgetWind = Wind(speed: 1.0)
let sampleWidget = WidgetWeatherData(weather: widgetWeather, main: widgetMain, wind: widgetWind, dt: 0, name: "サンプル")

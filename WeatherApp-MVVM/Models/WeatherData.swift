//
//  WeatherData.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/07.
//

import Foundation
import RxDataSources

struct WeatherData {
    var date: String
    var weather: String
    var highestTemperature: Double
    var lowestTemperature: Double
    var humidity: Int
}

struct SectionWeatherData {
    typealias Item = WeatherData
    var header: String
    var items: [WeatherData]
}
extension SectionWeatherData: SectionModelType {
    init(original: SectionWeatherData, items: [WeatherData]) {
        self = original
        self.items = items
    }
}

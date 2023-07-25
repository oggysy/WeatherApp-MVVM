//
//  SectionWeatherData.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/19.
//

import Foundation
import RxDataSources


struct SectionWeatherData {
    typealias Item = DisplayWeatherData
    var header: String
    var items: [Item]
}

extension SectionWeatherData: SectionModelType {
    init(original: SectionWeatherData, items: [Item]) {
        self = original
        self.items = items
    }
}

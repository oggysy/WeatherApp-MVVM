//
//  WeatherRecuest.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/24.
//

import Foundation
import Alamofire


protocol WeatherRequest {
    
    var baseURL: String { get }
    var path: String { get }
    var parameters: Parameters { get set }
}


extension WeatherRequest {
    var baseURL: String { "https://api.openweathermap.org" }
}

struct WeatherRequestModel: WeatherRequest {
    
    var path = "/data/2.5/forecast?"
    var parameters: Parameters = {
        let apikey = "5dfc577c1d7d94e9e23a00431582f1ac"
        let count = "8"
        let unit = "metric"
        let lang = "ja"
        return (["appid": apikey, "cnt": count, "units": unit, "lang": lang])
    }()
}

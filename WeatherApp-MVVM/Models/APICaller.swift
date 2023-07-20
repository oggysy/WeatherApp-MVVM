//
//  APICaller.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/13.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import Alamofire
import AlamofireImage

protocol WeatherAPIProtcol {
    func fetchWeatherData(at prefecture: String) -> Single<WeatherData>
    func fetchWeatherIcon(iconName: String) -> Single<Data>
}

class APICaller: WeatherAPIProtcol {
    
    func fetchWeatherData(at prefecture: String) -> Single<WeatherData> {
        return Single<WeatherData>.create { single in
            let decoder = JSONDecoder()
            let urlString = "https://api.openweathermap.org/data/2.5/forecast?"
            let apikey = "5dfc577c1d7d94e9e23a00431582f1ac"
            let count = "8"
            let unit = "metric"
            let parameters: Parameters = ["q": prefecture, "appid": apikey, "cnt": count, "units": unit]
            let request = AF.request(urlString, parameters: parameters).responseDecodable(of: WeatherData.self, decoder: decoder) { response in
                switch response.result {
                case .success:
                    if let weather = response.value {
                        single(.success(weather))
                    } else {
                        single(.failure(NError.nilData))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }

    
    func fetchWeatherIcon(iconName: String) -> Single<Data>{
        return Single.create { single in
            let iconUrl = "https://openweathermap.org/img/wn/\(iconName).png"
            let request = AF.request(iconUrl).response { response in
                if let data = response.data {
                    single(.success(data))
                } else {
                    single(.failure(NSError(domain: "", code: -1, userInfo: nil)))  // Error handling here
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

enum NError: Error {
    case nilData
}

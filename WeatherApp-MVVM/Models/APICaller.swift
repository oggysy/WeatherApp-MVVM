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
import CoreLocation

protocol WeatherAPIProtcol {
    func fetchWeatherData(request: WeatherRequestModel) -> Single<WeatherData>
    func fetchWeatherIcon(iconName: String) -> Single<Data>
    func setupRequest(prefecture: String) -> WeatherRequestModel
    func setupRequest(location: CLLocation) -> WeatherRequestModel
}

class APICaller: WeatherAPIProtcol {
    
    func setupRequest(prefecture: String) -> WeatherRequestModel {
        var request = WeatherRequestModel()
        request.parameters["q"] = prefecture
        return request
    }
    
    func setupRequest(location: CLLocation) -> WeatherRequestModel {
        var request = WeatherRequestModel()
        request.parameters["lat"] = String(location.coordinate.latitude)
        request.parameters["lon"] = String(location.coordinate.longitude)
        return request
    }
    
    func fetchWeatherData(request: WeatherRequestModel) -> Single<WeatherData> {
        return Single<WeatherData>.create { single in
            let decoder = JSONDecoder()
            let weatherRequest = AF.request(request.baseURL + request.path, parameters: request.parameters).responseDecodable(of: WeatherData.self, decoder: decoder) { response in
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
                weatherRequest.cancel()
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

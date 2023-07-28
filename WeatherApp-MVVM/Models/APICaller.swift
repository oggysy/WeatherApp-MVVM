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
    func fetchWeatherData<req: WeatherRequest>(request: req) -> Single<req.ResponseType>
    func fetchWeatherIcon(iconName: String) -> Single<Data?>
    func setupRequest<R: WeatherRequest>(prefecture: String, model: R) -> R
    func setupRequest<R: WeatherRequest>(location: CLLocation, model: R) -> R
}

class APICaller: WeatherAPIProtcol {
    
    func setupRequest<R: WeatherRequest>(prefecture: String, model: R) -> R {
        var model = model
        model.parameters["q"] = prefecture
        return model
    }
    
    func setupRequest<R: WeatherRequest>(location: CLLocation, model: R) -> R {
        var model = model
        model.parameters["lat"] = String(location.coordinate.latitude)
        model.parameters["lon"] = String(location.coordinate.longitude)
        return model
    }
    
    func fetchWeatherData<req: WeatherRequest>(request: req) -> Single<req.ResponseType> {
        return Single<req.ResponseType>.create { single in
            let decoder = JSONDecoder()
            // AF.requestでタイムアウト8秒、statusCode200番以外は.responseValidationFailedエラーで返すを設定
            let weatherRequest = AF.request(request.baseURL + request.path, parameters: request.parameters, requestModifier: { $0.timeoutInterval = 8.0 }).validate(statusCode:  200..<300).responseDecodable(of: req.ResponseType.self, decoder: decoder) { response in
                switch response.result {
                case .success:
                    if let weather = response.value {
                        single(.success(weather))
                    } else {
                        single(.failure(ResponseError.nilData))
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
    
    func fetchWeatherIcon(iconName: String) -> Single<Data?>{
        return Single.create { single in
            let iconUrl = "https://openweathermap.org/img/wn/\(iconName).png"
            let request = AF.request(iconUrl).response { response in
                single(.success(response.data))
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

enum ResponseError: Error {
    case nilData
}

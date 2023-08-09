//
//  WidgetAPICaller.swift
//  WeatherWidgetExtension
//
//  Created by 小木曽 佑介 on 2023/08/07.
//

import Foundation
import UIKit
import Alamofire

class WidgetAPICaller {
    
    static func fetchWeatherData(from url: String) async throws -> WidgetWeatherData {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url).responseDecodable(of: WidgetWeatherData.self) { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    static func fetchIconImage(from url: String) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url).responseData { response in
                switch response.result {
                case .success(let data):
                    let image = UIImage(data: data) ?? UIImage()
                    continuation.resume(returning: image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

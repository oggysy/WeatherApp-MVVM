//
//  TimeIntervarExt.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/21.
//

import Foundation


extension TimeInterval {
    public func changeDateString() -> String{
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    public func changeTimeString() -> String{
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let timeString = dateFormatter.string(from: date)
        return timeString
    }
}

//
//  UserNotification.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/31.
//
import UIKit
import UserNotifications


final class UserNotificationUnit : NSObject {
    static let shared = UserNotificationUnit()
    let center = UNUserNotificationCenter.current()
    
    func initialize() {
        center.delegate = UserNotificationUnit.shared
    }
    
    func showPushPermit(completion: @escaping (Result<Bool, Error>) -> Void) {
        center.requestAuthorization (options: [.alert, .badge, .sound]){ isGranted, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(.failure(error))
                return
            }
            completion(.success(isGranted))
        }
    }
    
    func createTimeRequest(hour: Int, minute: Int) -> UNNotificationRequest{
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: hour, minute: minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "天気予報アプリ"
        content.body = "今日の天気を確認しましょう"
        content.badge = 0
        content.sound = .defaultCritical
        return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    }
    
    func checkNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
}

extension UserNotificationUnit: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

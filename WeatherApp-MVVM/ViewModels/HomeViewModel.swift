//
//  HomeViewModel.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/14.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import RxCoreLocation

class HomeViewModel {
    
    private lazy var locationManager = CLLocationManager()
    private let locationSubject = PublishSubject<CLLocation>()
    var locationDriver: Driver<CLLocation> {
        return locationSubject.asDriver(onErrorJustReturn: CLLocation())
    }
    private let disposeBag = DisposeBag()
    private var didUpdateLocation = false //更新処理のフラグ
    private var locationAuthorizationStatus: CLAuthorizationStatus?
    private var locationErrorMessage = PublishRelay<String>()
    var locationErrorMessageDriver: Driver<String> {
        return locationErrorMessage.asDriver(onErrorJustReturn: "")
    }
    var bellButtonStatus: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var showSettingNotificationAlert = PublishRelay<Void>()
    var setNotificationTime = PublishRelay<[String: Int]>()
    var setNotificationResult = PublishRelay<(String, String)>()
    var setNotificationUnauthorized = PublishRelay<(String, String)>()
    
    init(locationButtonObservable: Signal<Void>, bellButtonObservable: Signal<Void>){
        self.locationManager.requestWhenInUseAuthorization()
        UserNotificationUnit.shared.showPushPermit { result in
            switch result {
            case .success(let isGranted):
                print(isGranted)
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }
        // 初期化時に通知設定があるかを確認し、状態をbellボタンに反映
        UserNotificationUnit.shared.center.getPendingNotificationRequests { request in
            if request.isEmpty {
                self.bellButtonStatus.accept(false)
            } else {
                self.bellButtonStatus.accept(true)
            }
        }
        
        disposeBag.insert(
            locationButtonObservable.emit(onNext: { _ in
                guard let status = self.locationAuthorizationStatus else { return }
                switch status {
                case .denied:
                    self.locationErrorMessage.accept("現在地を取得するにはGPSをオンにしてください")
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationManager.startUpdatingLocation()
                    self.didUpdateLocation = false
                default:
                    print("locationManagerの不明なエラー")
                }
            }),
            locationManager.rx
                .location
                .subscribe(onNext: { [weak self] newLocation in
                    guard let self = self else { return }
                    guard let newLocation = newLocation else {
                        self.locationErrorMessage.accept("位置情報の取得に失敗しました")
                        return }
                    if !self.didUpdateLocation {
                        self.locationSubject.onNext(newLocation)
                        self.locationManager.stopUpdatingLocation()  // 位置情報の取得を停止する
                        self.didUpdateLocation = true
                    }
                }),
            locationManager.rx.didChangeAuthorization.subscribe(onNext: { _, status in
                switch status {
                case .denied:
                    self.locationAuthorizationStatus = .denied
                case .notDetermined:
                    self.locationAuthorizationStatus = .notDetermined
                case .authorizedAlways:
                    self.locationAuthorizationStatus = .authorizedAlways
                case .authorizedWhenInUse:
                    self.locationAuthorizationStatus = .authorizedWhenInUse
                default:
                    print("locationManagerの不明なエラー")
                }
            }),
            bellButtonObservable.emit(onNext: { _ in
                UserNotificationUnit.shared.checkNotificationAuthorizationStatus { status in
                    switch status {
                    case .notDetermined:
                        self.setNotificationUnauthorized.accept(("通内が無効になっています","通知を有効にするためには設定を変更してください。"))
                    case .denied:
                        self.setNotificationUnauthorized.accept(("通内が無効になっています","通知を有効にするためには設定を変更してください。"))
                    case .authorized:
                        UserNotificationUnit.shared.center.getPendingNotificationRequests { request in
                            if request.isEmpty {
                                self.showSettingNotificationAlert.accept(())
                            } else {
                                UserNotificationUnit.shared.center.removeAllPendingNotificationRequests()
                                self.setNotificationResult.accept(("通知スケジュール削除完了","通知を削除しました"))
                                self.bellButtonStatus.accept(false)
                            }
                        }
                    default:
                        self.setNotificationUnauthorized.accept(("通内が無効になっています","通知を有効にするためには設定を変更してください。"))
                    }
                }
                
                
            }),
            setNotificationTime.subscribe(onNext: { times in
                let hour = times["hour"] ?? 0
                let minutes = times["minutes"] ?? 0
                let request = UserNotificationUnit.shared.createTimeRequest(hour: hour, minute: minutes)
                UserNotificationUnit.shared.center.add(request) { error in
                    if let error = error {
                        self.setNotificationResult.accept(("通知スケジュール失敗","通知の設定に失敗しました\(error)"))
                    } else {
                        let hour = String(hour)
                        let minutes = String(format: "%02d", minutes)
                        self.setNotificationResult.accept(("通知スケジュール成功","毎日\(hour)時\(minutes)分に通知がされます"))
                        self.bellButtonStatus.accept(true)
                    }
                }
            })
        )
    }
}


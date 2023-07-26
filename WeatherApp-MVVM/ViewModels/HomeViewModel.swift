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
    
    init(locationButtonObservable: Signal<Void>){
        self.locationManager.requestWhenInUseAuthorization()
        disposeBag.insert(
            locationButtonObservable.emit(onNext: { _ in
                guard let status = self.locationAuthorizationStatus else { return }
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationManager.startUpdatingLocation()
                    self.didUpdateLocation = false
                case .denied:
                    self.locationErrorMessage.accept("現在地を取得するにはGPSをオンにしてください")
                default:
                    print("locationManagerの不明なエラー")
                }
            }),
            locationManager.rx
                .location
                .compactMap { $0 }
                .subscribe(onNext: { [weak self] newLocation in
                    guard let self = self else { return }
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
                case .restricted:
                    self.locationAuthorizationStatus = .restricted
                case .authorizedAlways:
                    self.locationAuthorizationStatus = .authorizedAlways
                case .authorizedWhenInUse:
                    self.locationAuthorizationStatus = .authorizedWhenInUse
                default:
                    print("unknownError")
                }
            })
        )
    }
}


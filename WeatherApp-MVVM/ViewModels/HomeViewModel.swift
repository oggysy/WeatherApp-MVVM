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
    
    init(locationButtonObservable: Signal<Void>){
        self.locationManager.requestWhenInUseAuthorization()
        disposeBag.insert(
            locationButtonObservable.emit(onNext: { _ in
                self.locationManager.startUpdatingLocation()
                self.didUpdateLocation = false
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
                    
                })
        )
    }
}


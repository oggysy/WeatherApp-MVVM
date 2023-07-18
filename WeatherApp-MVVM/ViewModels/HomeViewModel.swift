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
    
    lazy var locationManager = CLLocationManager()
    let locationSubject = PublishSubject<CLLocation>()
    let disposeBag = DisposeBag()
    
    init(locationButtonObservable: Signal<Void>){
        self.locationManager.requestWhenInUseAuthorization()
        disposeBag.insert(
            locationButtonObservable.emit(onNext: { _ in
                self.locationManager.startUpdatingLocation()
            }),
            locationManager.rx
                .location
                .compactMap { $0 }
                .subscribe(onNext: { [weak self] newLocation in
                    self?.locationSubject.onNext(newLocation)
                    self?.locationManager.stopUpdatingLocation()  // 位置情報の取得を停止する
                })
        )
    }
}


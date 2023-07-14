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
    var location: Observable<CLLocation> {
        return locationSubject.asObservable()
    }
    let disposeBag = DisposeBag()
    
    init(locationButtonObservable: Observable<Void>){
        self.locationManager.requestWhenInUseAuthorization()
        locationButtonObservable.subscribe { _ in
            self.locationManager.startUpdatingLocation()
        }.disposed(by: disposeBag)
        
        locationManager.rx
                   .location
                   .compactMap { $0 }
                   .subscribe(onNext: { [weak self] newLocation in
                       self?.locationSubject.onNext(newLocation)
                       self?.locationManager.stopUpdatingLocation()  // 位置情報の取得を停止する
                   })
                   .disposed(by: disposeBag)
    }
}


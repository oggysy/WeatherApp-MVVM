//
//  DetailViewModel.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/12.
//

import Foundation
import RxSwift
import RxCocoa

class DetailViewModel {
    
    let weatherData = BehaviorRelay<[WeatherData]>(value: [])
    let selectedPrefecture = BehaviorRelay<String?>(value: nil)
    let weatherModel: weatherAPIProtcol
    let disposeBag = DisposeBag()
    
    init(selectedCellObservable: Observable<String>, weatherModel: weatherAPIProtcol) {
        self.weatherModel = weatherModel
        selectedCellObservable.subscribe { prefecture in
            self.selectedPrefecture.accept(prefecture)
        }
        .disposed(by: disposeBag)
    }
}

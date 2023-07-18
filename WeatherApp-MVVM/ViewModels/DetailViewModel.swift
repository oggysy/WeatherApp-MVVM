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
    
    var selectedPrefecture: BehaviorSubject<String>
    let weatherData = BehaviorRelay<[SectionWeatherData]>(value: [])
    var weatherDataDriver: Driver<[SectionWeatherData]> {
        weatherData.asDriver()
    }
    let fetchDataTrigger = PublishSubject<Void>()
    let weatherModel: WeatherAPIProtcol
    let disposeBag = DisposeBag()
    
    init(prefecture: String) {
        self.selectedPrefecture = BehaviorSubject(value: prefecture)
        weatherModel = APICaller()
        fetchDataTrigger.subscribe(onDisposed: { [weak self] in
            let data = try? self?.weatherModel.fetchWeatherData(at: self?.selectedPrefecture.value() ?? "")
            guard let data = data else { return }
            self?.weatherData.accept(data)
        })
        .disposed(by: disposeBag)
    }
}

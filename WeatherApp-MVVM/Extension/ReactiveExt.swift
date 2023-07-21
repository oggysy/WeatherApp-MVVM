//
//  ReactiveExt.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/21.
//

import Foundation
import RxSwift
import Charts
import DGCharts

// RxSwiftでChartsを使ってbindさせるためのExtension
extension Reactive where Base: LineChartView {
    var chartData: Binder<LineChartData> {
        return Binder(self.base) { (view: LineChartView, data: LineChartData) in
            view.data = data
        }
    }
}

extension Reactive where Base: XAxis {
    var valueFormatter: Binder<IndexAxisValueFormatter> {
        return Binder(self.base) { view, formatter in
            view.valueFormatter = formatter
        }
    }
}



//
//  LoadingView.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/26.
//

import Foundation
import UIKit


class LoadingView: UIView {
    public let indicator: UIActivityIndicatorView // 使用する側から指定できるようにプロパティで持つ
    
    init() {
        indicator = UIActivityIndicatorView(style: .large)
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.isUserInteractionEnabled = false // タップイベントを無効化(indicatorで設定するとタップが透過する)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            indicator.topAnchor.constraint(equalTo: self.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setFillSuperview(for view: UIView) {
        view.addSubview(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
}

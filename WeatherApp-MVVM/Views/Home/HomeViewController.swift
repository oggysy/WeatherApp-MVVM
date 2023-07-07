//
//  HomeViewController.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    let dispose = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        selectButton.rx.tap.subscribe { _ in
            self.navigationController?.pushViewController(SelectViewController(), animated: true)
        }.disposed(by: dispose)
        currentLocationButton.rx.tap.subscribe { _ in
            self.present(DetailViewController(), animated: true)
        }.disposed(by: dispose)
    }
}

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
        setUpNavigationBar()
        setUpButtonAction()
    }
    
    @objc func rightButtonTapped() {
        // ベルボタンタップの処理を後で実装
    }
    
    func setUpNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Home"
        let navBarAppearance = {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .systemOrange
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            return appearance
        }()
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(rightButtonTapped))
        rightButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func setUpButtonAction() {
        selectButton.rx.tap.subscribe { _ in
            self.navigationController?.pushViewController(SelectViewController(), animated: true)
        }.disposed(by: dispose)
        currentLocationButton.rx.tap.subscribe { _ in
            self.present(DetailViewController(), animated: true)
        }.disposed(by: dispose)
        
        selectButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
    }
}

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
    lazy var viewModel: HomeViewModel = { [self] in
        return HomeViewModel(locationButtonObservable: currentLocationButton.rx.tap.asSignal())
    }()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpButtonAction()
    }
    
    @objc func rightButtonTapped() {
        // ベルボタンタップの処理を後で実装
    }
    
    private func setUpNavigationBar() {
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
    
    private func setUpButtonAction() {
        disposeBag.insert(
            selectButton.rx.tap.asSignal().emit { [weak self] _ in
                self?.navigationController?.pushViewController(SelectViewController(), animated: true)
            },
            viewModel.locationDriver.drive(onNext: { newLocation in
                let vc = DetailViewController()
                vc.viewModel = DetailViewModel(location: newLocation)
                self.present(vc, animated: true)
            }),
            viewModel.locationErrorMessageDriver.drive(onNext: { message in
                self.showGPSAlert(message: message)
            })
        )
        selectButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
    }
    private func showGPSAlert(message: String) {
        let alert = UIAlertController(title: "GPSがオフです", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        if message == "現在地を取得するにはGPSをオンにしてください" {
            alert.addAction(UIAlertAction(title: "設定", style: .default, handler: { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
        }
        present(alert, animated: true, completion: nil)
    }
}

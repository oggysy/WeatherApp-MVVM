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
        return HomeViewModel(locationButtonObservable: currentLocationButton.rx.tap.asObservable())
    }()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpButtonAction()
        viewModel.locationSubject.subscribe { newLocation in
            print(newLocation)
            let vc = DetailViewController()
            vc.viewModel = DetailViewModel(prefecture: "東京都") //仮で東京都を入れている
            self.present(vc, animated: true)
        }.disposed(by: disposeBag)
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
        disposeBag.insert(
<<<<<<< HEAD
            selectButton.rx.tap.subscribe { _ in
                self.navigationController?.pushViewController(SelectViewController(), animated: true)
=======
            selectButton.rx.tap.subscribe { [weak self] _ in
                self?.navigationController?.pushViewController(SelectViewController(), animated: true)
            },
            currentLocationButton.rx.tap.subscribe { [weak self] _ in
                self?.present(DetailViewController(), animated: true)
                
                )
                selectButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
                currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
            }
            }
>>>>>>> 9560d2a (コンフリクト解決)
            }

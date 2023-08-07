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
    var naviBarRightButton: UIBarButtonItem = {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: nil, action: nil)
        rightButton.tintColor = .white
        return rightButton
    }()
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel(locationButtonObservable: currentLocationButton.rx.tap.asSignal(), bellButtonObservable: naviBarRightButton.rx.tap.asSignal())
    }()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpButtonAction()
    }
    
    @objc func rightButtonTapped() {
        showSettingNotificationAlert()
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
        navigationItem.rightBarButtonItem = naviBarRightButton
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
            }),
            viewModel.bellButtonStatus.asDriver(onErrorJustReturn: false).drive(onNext: { isEnable in
                self.naviBarRightButton.image = isEnable ? UIImage(systemName: "bell") : UIImage(systemName: "bell.slash")
            }),
            viewModel.showSettingNotificationAlert.asDriver(onErrorJustReturn: ()).drive(onNext: { _ in
                self.showSettingNotificationAlert()
            }),
            viewModel.setNotificationResult.asDriver(onErrorJustReturn: ("","")).drive(onNext: { (title, message) in
                self.showNotificationResultAlert(title: title, message: message)
            }),
            viewModel.setNotificationUnauthorized.asDriver(onErrorJustReturn: ("","")).drive(onNext: { (title, message) in
                self.showNotificationUnauthorizedAlert(title: title, message: message)
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
    
    private func showSettingNotificationAlert() {
        let title = "通知したい時間を選択"
        let message: String? = nil
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .time
        pickerView.locale = Locale.current
        pickerView.timeZone = TimeZone.current
        alert.view.addSubview(pickerView)

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            pickerView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -60),
            pickerView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor)
        ])
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
        }
        let okAction = UIAlertAction(title: "設定", style: .default) { _ in
            let hour = Calendar.current.component(.hour, from: pickerView.date)
            let minutes = Calendar.current.component(.minute, from: pickerView.date)
            self.viewModel.setNotificationTime.accept(["hour": hour, "minutes": minutes])
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNotificationResultAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showNotificationUnauthorizedAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定", style: .default) { (_) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, completionHandler: nil)
                }
            }
        alert.addAction(settingsAction)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}

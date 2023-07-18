//
//  SelectViewController.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit
import RxSwift
import RxCocoa

class SelectViewController: UIViewController {
    // viewModelにセルタップのObservableを渡して初期化
    private lazy var viewModel: SelectViewModel = SelectViewModel(
    )
    let disposeBag = DisposeBag()
    @IBOutlet weak var prefecturesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        settingNavigationBar()
        prefecturesTableView.register(UINib(nibName: "SelectTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectTableViewCell")
        disposeBag.insert(
            // 都道府県一覧のテーブルビューを作成
            viewModel.prefecturesDriver.drive(prefecturesTableView.rx.items(cellIdentifier: "SelectTableViewCell", cellType: SelectTableViewCell.self)) { row, element, cell in
                cell.prefectureNameLabel.text = element
            },
            prefecturesTableView.rx.modelSelected(String.self).asSignal().emit(onNext: { [weak self] prefecture in
                let vc = DetailViewController()
                vc.viewModel = DetailViewModel(prefecture: prefecture)
                self?.present(vc, animated: true)
            })
        )
    }
    
    func settingNavigationBar(){
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "都道府県の選択"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

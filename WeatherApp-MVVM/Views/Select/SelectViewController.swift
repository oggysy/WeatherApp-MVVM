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
    
    let prefectures = Observable<[String]>.just([
        "北海道",
        "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
        "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
        "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県",
        "三重県", "滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
        "鳥取県", "島根県", "岡山県", "広島県", "山口県",
        "徳島県", "香川県", "愛媛県", "高知県",
        "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県",
        "沖縄県"
    ])
    
    let disposeBag = DisposeBag()
    
    
    
    @IBOutlet weak var prefecturesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "都道府県の選択"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
        
        prefecturesTableView.register(UINib(nibName: "SelectTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectTableViewCell")
        prefectures.bind(to: prefecturesTableView.rx.items(cellIdentifier: "SelectTableViewCell", cellType: SelectTableViewCell.self)) { row, element, cell in
            cell.prefectureNameLabel.text = element
        }.disposed(by: disposeBag)
        
        // 後々、選択されたセルの都道府県名を渡せるようにmodelSelectedを使用
        prefecturesTableView.rx.modelSelected(String.self).subscribe(onNext: { selectedPrefecture in
            self.present(DetailViewController(), animated: true)
        })
        .disposed(by: disposeBag)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

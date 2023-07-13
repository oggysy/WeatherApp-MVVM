//
//  DetailViewController.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    // ViewModelにはセル選択のObservableとAPIを呼ぶModelを渡す
//    private lazy var viewModel: DetailViewModel = DetailViewModel(
//        selectedCellObservable: prefecturesTableView.rx.modelSelected(String.self).asObservable(),
//        weatherModel: APICaller()
//     ))
    let selectedPrefecture: String
//    let disposeBag = DisposeBag()
//
    init(at selectedCell: String){
        self.selectedPrefecture = selectedCell
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print(selectedPrefecture)
    }
    //
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        detailTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
//        detailViewModel.weatherData.bind(to: detailTableView.rx.items(cellIdentifier: "DetailTableViewCell", cellType: DetailTableViewCell.self)) {
//            row, element, cell in
//            cell.dateLabel.text = element.date
//            cell.weatherImageView.image = UIImage(named: element.weather)
//            cell.highestTempLabel.text = String(element.highestTemperature)
//            cell.lowestTempLabel.text = String(element.lowestTemperature)
//            cell.humidity.text = String(element.humidity)
//        }.disposed(by: disposeBag)
//
//        closeButton.rx.tap.subscribe { _ in
//            self.dismiss(animated: true)
//        }.disposed(by: disposeBag)
//    }
}

//
//extension DetailViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = detailTableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath)
//        return cell
//    }
//}

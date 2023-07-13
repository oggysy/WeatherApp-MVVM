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
    
    
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel: DetailViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { return }
        detailTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
        disposeBag.insert(
            // viewModelのweatherDataにtableViewをバインド
            viewModel.weatherData.bind(to: detailTableView.rx.items(cellIdentifier: "DetailTableViewCell", cellType: DetailTableViewCell.self)) {
                row, element, cell in
                cell.dateLabel.text = element.date
                cell.weatherImageView.image = UIImage(named: element.weather)
                cell.highestTempLabel.text = String(element.highestTemperature)
                cell.lowestTempLabel.text = String(element.lowestTemperature)
                cell.humidity.text = String(element.humidity)
            },
            Observable.just(()).bind(to: viewModel.fetchDataTrigger),
            closeButton.rx.tap.subscribe { _ in
                self.dismiss(animated: true)
            },
            viewModel.selectedPrefecture.bind(to: prefectureLabel.rx.text)
        )
    }
}

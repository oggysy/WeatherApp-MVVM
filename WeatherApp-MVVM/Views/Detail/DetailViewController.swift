//
//  DetailViewController.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

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
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionWeatherData>(
            configureCell: { [weak self] (dataSource, tableView, indexPath, item) in
                guard let cell = self?.detailTableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else { return UITableViewCell() }
                cell.dateLabel.text = item.date
                cell.highestTempLabel.text = "最高気温:\(String(item.highestTemperature))℃"
                cell.lowestTempLabel.text = "最低気温:\(String(item.lowestTemperature))℃"
                cell.humidity.text = "湿度:\(String(item.humidity))%"
                cell.weatherImageView.image = UIImage(named: item.weather)
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            }
        )

        disposeBag.insert(
            // viewModelのweatherDataにtableViewをバインド
            viewModel.weatherData.asObservable().bind(to: detailTableView.rx.items(dataSource: dataSource)),
            Observable.just(()).bind(to: viewModel.fetchDataTrigger),
            closeButton.rx.tap.subscribe { _ in
                self.dismiss(animated: true)
            },
            viewModel.selectedPrefecture.bind(to: prefectureLabel.rx.text)
        )
    }
}

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
import Charts
import DGCharts

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var popChartView: LineChartView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    public var viewModel: DetailViewModel?
    private let disposeBag = DisposeBag()
    private let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { return }
        loadingView.setFillSuperview(for: view)
        detailTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionWeatherData>(
            configureCell: { [weak self] (dataSource, tableView, indexPath, item) in
                guard let cell = self?.detailTableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell else { return UITableViewCell() }
                cell.dateLabel.text = item.time
                cell.highestTempLabel.text = "最高気温:\(item.maxTemparture)℃"
                cell.lowestTempLabel.text = "最低気温:\(item.minTemparture)℃"
                cell.humidity.text = "湿度:\(item.humidity)%"
                cell.weatherImageView.image = UIImage(data: item.iconData)
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            }
        )
        
        disposeBag.insert(
            closeButton.rx.tap.subscribe { _ in
                self.dismiss(animated: true)
            },
            viewModel.weatherData.asDriver(onErrorJustReturn: []).drive(detailTableView.rx.items(dataSource: dataSource)),
            viewModel.selectedPrefecture.asDriver(onErrorJustReturn: "エラー").drive(prefectureLabel.rx.text),
            viewModel.chartData.asDriver(onErrorJustReturn: LineChartData()).drive(popChartView.rx.chartData),
            viewModel.chartFormatter.asDriver(onErrorJustReturn: IndexAxisValueFormatter()).drive(popChartView.xAxis.rx.valueFormatter),
            viewModel.todayDate.asDriver(onErrorJustReturn: "").drive(dateLabel.rx.text),
            viewModel.isLoadingDriver.drive(loadingView.indicator.rx.isAnimating),
            viewModel.isLoadingDriver.map { !($0) }.drive(loadingView.rx.isHidden),
            viewModel.isLoadingDriver.map { !($0) }.drive(view.rx.isUserInteractionEnabled),
            viewModel.APIErrorMessage.asDriver(onErrorJustReturn: "").drive(onNext: { message in
                let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: { _ in
                    self.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            })
        )
        displayChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.fetch()
    }
    
    private func displayChart() {
        popChartView.xAxis.granularity = 1
        popChartView.highlightPerTapEnabled = false
        popChartView.legend.enabled = false
        popChartView.pinchZoomEnabled = false
        popChartView.doubleTapToZoomEnabled = false
        popChartView.leftAxis.axisMaximum = 100
        popChartView.leftAxis.axisMinimum = 0
        popChartView.leftAxis.labelCount = 6
        popChartView.xAxis.labelPosition = .bottom
        popChartView.rightAxis.enabled = false
        popChartView.animate(xAxisDuration: 2)
    }
}

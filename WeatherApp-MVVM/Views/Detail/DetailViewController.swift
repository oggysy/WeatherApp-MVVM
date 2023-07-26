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
    private let loadingView: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            return indicator
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { return }
        setupLoadingView()
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
            Observable.just(()).bind(to: viewModel.fetchDataTrigger),
            viewModel.weatherDataDriver.drive(detailTableView.rx.items(dataSource: dataSource)),
            viewModel.selectedPrefecture.bind(to: prefectureLabel.rx.text),
            viewModel.chartDataDriver.drive(popChartView.rx.chartData),
            viewModel.chartFormatterDriver.drive(popChartView.xAxis.rx.valueFormatter),
            viewModel.todayDateDriver.drive(dateLabel.rx.text),
            viewModel.isLoading.bind(to: loadingView.rx.isAnimating),
            viewModel.isLoading
                        .map { !($0) }
                        .bind(to: loadingView.rx.isHidden)
        )
        displayChart()
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
    
    
    private func setupLoadingView() {
           view.addSubview(loadingView)
           NSLayoutConstraint.activate([
               loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               loadingView.topAnchor.constraint(equalTo: view.topAnchor),
               loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           ])
       }
}

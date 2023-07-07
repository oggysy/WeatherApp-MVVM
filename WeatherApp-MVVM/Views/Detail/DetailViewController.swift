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
    let disposeBag = DisposeBag()
    let weatherData = Observable<[WeatherData]>.just([
        WeatherData(date: "0:00", weather: "sunny", highestTemperature: 15.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "3:00", weather: "sunny", highestTemperature: 20.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "6:00", weather: "sunny", highestTemperature: 22.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "9:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "12:00", weather: "sunny", highestTemperature: 25.0, lowestTemperature: 20.0, humidity: 50),
        WeatherData(date: "15:00", weather: "sunny", highestTemperature: 30.0, lowestTemperature: 20.0, humidity: 50)
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        weatherData.bind(to: detailTableView.rx.items(cellIdentifier: "DetailTableViewCell", cellType: DetailTableViewCell.self)) {
            row, element, cell in
            cell.dateLabel.text = element.date
            cell.weatherImageView.image = UIImage(named: element.weather)
            cell.highestTempLabel.text = String(element.highestTemperature)
            cell.lowestTempLabel.text = String(element.lowestTemperature)
            cell.humidity.text = String(element.humidity)
        }.disposed(by: disposeBag)
        
        
        closeButton.rx.tap.subscribe { _ in
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
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

//
//  DetailViewController.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        detailTableView.dataSource = self
    }
    
    @IBAction func closedButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath)
        return cell
    }
}

//
//  HomeViewController.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(SelectViewController(), animated: true)
    }
    
    @IBAction func currentLocationButtonTapped(_ sender: UIButton) {
        self.present(DetailViewController(), animated: true)
    }
}

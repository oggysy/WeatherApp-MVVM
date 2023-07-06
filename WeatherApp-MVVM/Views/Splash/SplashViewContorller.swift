//
//  SplashViewContorller.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit

class SplashViewContorller: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let viewContoroller = HomeViewController()
            viewContoroller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.navigationController?.pushViewController(viewContoroller, animated: true)
        }
    }
}

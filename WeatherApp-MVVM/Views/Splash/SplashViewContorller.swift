//
//  SplashViewContorller.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit

class SplashViewContorller: UIViewController {
    
    
    @IBOutlet weak var splashImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rotationAnimation = {
            let animation = CABasicAnimation(keyPath:"transform.rotation.z")
            animation.toValue = CGFloat(Double.pi / 180) * 360
            animation.duration = 2.0
            return animation
        }()
        
        splashImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let viewContoroller = HomeViewController()
            viewContoroller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.navigationController?.pushViewController(viewContoroller, animated: true)
        }
    }
}

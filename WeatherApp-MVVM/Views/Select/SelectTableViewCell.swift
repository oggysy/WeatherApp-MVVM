//
//  SelectTableViewCell.swift
//  WeatherApp-MVVM
//
//  Created by 小木曽 佑介 on 2023/07/06.
//

import UIKit

class SelectTableViewCell: UITableViewCell {

    @IBOutlet weak var prefectureNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

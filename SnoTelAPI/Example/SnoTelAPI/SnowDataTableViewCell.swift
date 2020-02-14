//
//  SnowDataTableViewCell.swift
//  SnoTelAPI_Example
//
//  Created by Jim Terhorst on 2/13/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SnoTelAPI

class SnowDataTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var accumulatedSnowLabel: UILabel!
    
    public var station: Station?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

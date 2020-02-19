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
    @IBOutlet weak var periodSnowAccumulation: UILabel!
    
    public var station: Station?
    public var snowData: SnowData? {
        didSet {
            if let snowData = self.snowData {
                self.dateLabel?.text = SnotelStationTableViewController.timeFormatter.string(from: snowData.date)
                if let airTemperature = self.snowData?.airTemperature {
                    self.temperatureLabel?.text = "\(airTemperature)"
                } else {
                    self.temperatureLabel?.text = "--"
                }
                
                if let snowDepth = snowData.snowDepth {
                    self.accumulatedSnowLabel?.text = "\(snowDepth)"
                } else {
                    self.accumulatedSnowLabel?.text = "--"
                }
                
                if let snowDepthDelta = snowData.snowDepthDelta {
                    self.periodSnowAccumulation?.text = "\(snowDepthDelta)"
                } else {
                    self.periodSnowAccumulation?.text = "--"
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

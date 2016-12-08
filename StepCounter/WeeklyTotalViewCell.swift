//
//  WeeklyTotalViewCell.swift
//  StepCounter
//
//  Created by sc on 08/12/2016.
//  Copyright © 2016 sc. All rights reserved.
//

import UIKit

class WeeklyTotalViewCell: UITableViewCell {
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


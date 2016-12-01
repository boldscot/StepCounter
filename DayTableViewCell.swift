//
//  DayTableViewCell.swift
//  StepCounter
//
//  Created by sc on 30/11/2016.
//  Copyright © 2016 sc. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var stepsForDay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

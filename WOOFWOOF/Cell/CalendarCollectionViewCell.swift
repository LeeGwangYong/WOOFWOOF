//
//  CalendarCollectionViewCell.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import KDCircularProgress

class CalendarCollectionViewCell: UICollectionViewCell {
    @IBOutlet var progressBar: KDCircularProgress!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var weekdayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

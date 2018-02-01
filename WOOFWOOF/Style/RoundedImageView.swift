//
//  RoundedImageView.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImageView: UIImageView {
    
    override func awakeFromNib() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor(displayP3Red: 37/255, green: 154/255, blue: 79/255, alpha: 1).cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }

}

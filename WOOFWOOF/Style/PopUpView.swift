//
//  PopUpView.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class PopUpView: UIView {
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
    }
    
    @objc func closeView(){
        self.removeFromSuperview()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
}

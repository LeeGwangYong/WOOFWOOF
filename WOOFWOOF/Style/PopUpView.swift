//
//  PopUpView.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit

class PopUpView: UIView {
    
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var backView: UIView!
    override func awakeFromNib() {
        self.backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
    }
    
    @objc func closeView(){
        self.removeFromSuperview()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }

    override func removeFromSuperview() {
        UIView.animate(withDuration: 1) {
            self.alpha = 0
        }
        super.removeFromSuperview()
    }
    
}

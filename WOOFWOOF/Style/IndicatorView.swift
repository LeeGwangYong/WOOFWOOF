//
//  IndicatorView.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import Lottie

class IndicatorView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var animationView: LOTAnimationView?
    
    override func awakeFromNib() {
        animationView = LOTAnimationView(name: "bluetooth")
        let imageView = UIImageView(image: #imageLiteral(resourceName: "wallpaper"))
        animationView?.addSubview(imageView , toKeypathLayer: LOTKeypath(string: "Placeholder"))
        //let cgPoint = animationView?.convert(CGPoint(), fromKeypathLayer: LOTKeypath(string: "Placeholder"))
        animationView?.center = self.center
        animationView?.frame = self.frame
        
        
        //imageView.center = (animationView?.center)!
        self.addSubview(animationView!)
        animationView?.loopAnimation = true
        animationView?.play()
    }
}

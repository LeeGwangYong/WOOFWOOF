//
//  ChartViewController.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    var planArray = Plan.realm.objects(Plan.self)
    @IBOutlet var profileImage: RoundedImageView!
    @IBOutlet var educationTime: UILabel!
    @IBOutlet var planCollectionView: UICollectionView!
    var popUp: PopUpView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.image = Profile.getProfile()
        educationTime.minimumScaleFactor = 0.1
        self.planCollectionView.setUp(target: self, cell: InstructionCollectionViewCell.self)
        popUp = UINib(nibName: PopUpView.reuseIdentifier, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! PopUpView
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return planArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: InstructionCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.thumbnail.image = UIImage(data: planArray[indexPath.row].image)
        cell.thumbnail.alpha = planArray[indexPath.row].active ? 1 : 0.5
        cell.nameLabel.text = planArray[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3.3, height:  collectionView.frame.height / 3.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !planArray[indexPath.row].active{
            self.popUp.frame = self.view.frame
            self.popUp.alpha = 0
            if planArray[indexPath.row].title == "downOn" {
                Plan.updateRealm(title: "downOn", active: true)
            }
            
            self.popUp.buyButton.setTitleColor(indexPath.row == 1 ? UIColor.white : UIColor.gray, for: .normal)
            self.parent?.parent?.view.addSubview(popUp)
            UIView.animate(withDuration: 1, animations: {
                self.popUp.alpha = 1
                if indexPath.row == 1 {self.planCollectionView.reloadData()}
                self.view.layoutIfNeeded()
                
            })
        }
    }
    
}

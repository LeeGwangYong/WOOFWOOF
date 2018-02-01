//
//  ViewController.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import CoreBluetooth
import Realm
import RealmSwift

class InstructionViewController: UIViewController {
    //MARK -: Property
    var instructionArray = Instruction.realm.objects(Instruction.self)
    var popUp: PopUpView!
    
    @IBOutlet var instructionCollectionView: UICollectionView!
    @IBOutlet var remoteView: UIView!
    @IBOutlet var heightLayout: NSLayoutConstraint!
    @IBOutlet var editButton: UIButton!
    
    //MARK -: Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.instructionCollectionView.setUp(target: self, cell: InstructionCollectionViewCell.self)
        popUp = UINib(nibName: PopUpView.reuseIdentifier, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! PopUpView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    var editFlag = true
    @IBAction func editAction(_ sender: UIButton) {
        let guide = self.view.safeAreaLayoutGuide
        let height = guide.layoutFrame.size.height
        editFlag = editFlag ? false : true
        let viewHeight = editFlag ? 225 : height * 0.8
        editButton.setTitle(editFlag ? "편집" : "저장", for: .normal)
        editButton.setTitleColor(editFlag ? UIColor(displayP3Red: 150/255, green: 150/255, blue: 150/255, alpha: 1) : UIColor(displayP3Red: 193/255, green: 14/255, blue: 72/255, alpha: 1), for: .normal)
        editButton.borderColor = editButton.currentTitleColor
        
        UIView.animate(withDuration: 1) {
            self.heightLayout.constant = viewHeight
            self.instructionCollectionView.reloadData()
            self.view.layoutIfNeeded()
        }
    }
}

extension InstructionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: InstructionCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)// as! InstructionCollectionViewCell
        cell.thumbnail.image  = UIImage(data: instructionArray[indexPath.row].image)
        cell.nameLabel.text = instructionArray[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if instructionArray.count < 4 { return instructionArray.count }
        return editFlag ? 3 : instructionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = editFlag ? self.instructionCollectionView.frame.height : self.instructionCollectionView.frame.height / 3.3
        return CGSize(width: collectionView.frame.width / 3.3, height: height )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row < 3 {
            let value: UInt8 = UInt8(exactly: instructionArray[indexPath.row].value)!
            let data = Data(bytes: [value])
            if PeripheralInfo.peripheral != nil {
                if let character = PeripheralInfo.character {
                    PeripheralInfo.peripheral.writeValue(data, for: character, type: .withoutResponse)
                }
            }
            else {
                print("Not Connect")
            }
            
        } else {
            self.popUp.frame = self.view.frame
            self.popUp.alpha = 0
            self.parent?.parent?.view.addSubview(popUp)
            UIView.animate(withDuration: 1, animations: {
                self.popUp.alpha = 1
                self.view.layoutIfNeeded()
        
            })
        }
    }
}

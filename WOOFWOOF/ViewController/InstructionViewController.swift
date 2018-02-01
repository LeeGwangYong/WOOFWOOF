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

struct PeripheralInfo{
    static let name = "HMSoft"
    static let service_UUID =
        CBUUID(string: "FFE0")
    static let characteristic_UUID =
        CBUUID(string: "FFE1")
}


class InstructionViewController: UIViewController {
    //MARK -: Property
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    var character: CBCharacteristic?
    
    var instructionArray = Instruction.realm.objects(Instruction.self)
    
    @IBOutlet var instructionCollectionView: UICollectionView!
    @IBOutlet var remoteView: UIView!
    @IBOutlet var heightLayout: NSLayoutConstraint!
    @IBOutlet var editButton: UIButton!
    
    //MARK -: Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpBluetooth()
        self.instructionCollectionView.setUp(target: self, cell: InstructionCollectionViewCell.self)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            write(title: "sitOn", name: "앉아", image: #imageLiteral(resourceName: "sitOn"), value: 1)
            write(title: "downOn", name: "엎드려", image: #imageLiteral(resourceName: "downOn"), value: 2)
            write(title: "waitOn", name: "기다려", image: #imageLiteral(resourceName: "waitOn"), value: 3)
            write(title: "comeOff", name: "이리와", image: #imageLiteral(resourceName: "comeOff"), value: 0)
            write(title: "handOff", name: "손", image: #imageLiteral(resourceName: "handOff"), value: 0)
            write(title: "barkOff", name: "짖어", image: #imageLiteral(resourceName: "barkOff"), value: 0)
            write(title: "bangOff", name: "빵야", image: #imageLiteral(resourceName: "bangOff"), value: 0)
            write(title: "standOff", name: "일어서", image: #imageLiteral(resourceName: "standOff"), value: 0)
            write(title: "rollOff", name: "굴러", image: #imageLiteral(resourceName: "rollOff"), value: 0)
        }
    }
    func write(title: String, name: String, image: UIImage, value: Int) {
        let inst: Instruction = Instruction()
        inst.title = title
        inst.name = name
        inst.image = UIImagePNGRepresentation(image)!
        inst.value = value
        Instruction.addToRealm(inst)
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
        editButton.setTitleColor(editFlag ? UIColor(displayP3Red: 202/255, green: 202/255, blue: 202/255, alpha: 1) : UIColor(displayP3Red: 193/255, green: 14/255, blue: 72/255, alpha: 1), for: .normal)
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
        let height = editFlag ? self.instructionCollectionView.frame.height : self.instructionCollectionView.frame.height / 3
        return CGSize(width: collectionView.frame.width / 3.3, height: height )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row < 4 {
            let value: UInt8 = UInt8(exactly: instructionArray[indexPath.row].value)!
            let data = Data(bytes: [value])
            if let character = self.character {
                peripheral.writeValue(data, for: character, type: .withoutResponse)
            }
        } else {
            
        }
    }
}

extension InstructionViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func setUpBluetooth() {
        self.manager = CBCentralManager(delegate: self, queue: nil)
        self.manager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("The state of the BLE Manager is unknown.")
        case .resetting:
            print("The BLE Manager is resetting; a state update is pending.")
        case .unsupported:
            print("This device does not support Bluetooth Low Energy.")
        case .unauthorized:
            print("This app is not authorized to use Bluetooth Low Energy.")
        case .poweredOff:
            print("Bluetooth on this device is currently powered off.")
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        print("Peripheral Name : \(advertisementData[CBAdvertisementDataLocalNameKey])")
        
        if device?.contains(PeripheralInfo.name) == true {
            self.manager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            manager.connect(peripheral, options: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("DidReadRSSI : \(RSSI)")
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        print("peripheralDidUpdateRSSI : \(peripheral.rssi)")
        //        DispatchQueue.global(qos: .background).async {
        //            var timer = Timer()
        //            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.readRSSI), userInfo: nil, repeats: true)
        //        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            
            let cbservcie = service as CBService
            print(cbservcie.uuid)
            if cbservcie.uuid == PeripheralInfo.service_UUID {
                peripheral.discoverCharacteristics(nil, for: cbservcie)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let cbcharacteristic = characteristic as CBCharacteristic
            print(cbcharacteristic.uuid)
            if cbcharacteristic.uuid == PeripheralInfo.characteristic_UUID {
                self.character = cbcharacteristic
                self.peripheral.setNotifyValue(true, for: cbcharacteristic) //주기적인 업데이트
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //백그라운드에서 받는 게 가능할까?
        print(characteristic.uuid)
        //        var count:UInt8 = 1
        //        //notification에 설정된 characteristic이 update될 때, 해당 delegate method 실행
        //        if characteristic.uuid == PeripheralInfo.scratch_UUID {
        //            if let data = characteristic.value {
        //                data.copyBytes(to: &count, count: MemoryLayout<UInt8>.size)
        //                print(count)
        //            }
        //        }
        
        //        self.peripheral.readRSSI()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //if disconnect peripheral, reconnect peripheral
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    
}


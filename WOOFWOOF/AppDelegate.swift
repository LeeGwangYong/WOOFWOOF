//
//  AppDelegate.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import CoreBluetooth
import UserNotifications
import Lottie

struct PeripheralInfo{
    static let name = "WF2"
    static let service_UUID =
        CBUUID(string: "FFE0")
    static let characteristic_UUID =
        CBUUID(string: "FFE1")
    static var currentRSSI:NSNumber = 0
    
    static var manager:CBCentralManager! 
    static var peripheral:CBPeripheral!
    static var character: CBCharacteristic?
    
    static var currentMy:MTMapPoint?
    static var currentDog:MTMapPoint?
    static var dogTime: Date?
    
    static var flag = true
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var i = 0
    var animationView: LOTAnimationView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        animationView = LOTAnimationView(name: "bluetooth")
        animationView?.contentMode = .scaleAspectFill
        
        animationView?.frame = CGRect(x: 10, y: 55, width: 50  , height: 50)
        window?.rootViewController?.view.addSubview(animationView!)
        animationView?.loopAnimation = true
        animationView?.pause()

        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            
            print(realmURL.absoluteString)
//                        do {
//                            try FileManager().removeItem(at: realmURL)
//                        }
//                        catch {
//                            fatalError("Couldn't remove Realm DB")
//                        }
        }
        
        if self.window!.rootViewController as? UITabBarController != nil {
            var tababarController = self.window!.rootViewController as! UITabBarController
            tababarController.selectedIndex = 1
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
            // handle error if there is one
        })
        UNUserNotificationCenter.current().delegate = self
        
        setUpDatabase()
        setUpBluetooth()
        NotificationCenter.default.post(name: .peripheralState, object: nil, userInfo: ["state" : false])
        
        return true
    }
    
    func setUpDatabase() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            Instruction.write(title: "sitOn", name: "앉아", image: #imageLiteral(resourceName: "sitMain"), value: 1)
            Instruction.write(title: "downOn", name: "엎드려", image: #imageLiteral(resourceName: "downMain"), value: 2)
            Instruction.write(title: "waitOn", name: "기다려", image: #imageLiteral(resourceName: "waitMain"), value: 3)
            Instruction.write(title: "comeOff", name: "이리와", image: #imageLiteral(resourceName: "comeOff"), value: 0)
            Instruction.write(title: "handOff", name: "손", image: #imageLiteral(resourceName: "handOff"), value: 0)
            Instruction.write(title: "barkOff", name: "짖어", image: #imageLiteral(resourceName: "barkOff"), value: 0)
            Instruction.write(title: "bangOff", name: "빵야", image: #imageLiteral(resourceName: "bangOff"), value: 0)
            Instruction.write(title: "standOff", name: "일어서", image: #imageLiteral(resourceName: "standOff"), value: 0)
            Instruction.write(title: "rollOff", name: "굴러", image: #imageLiteral(resourceName: "rollOff"), value: 0)
            
            Plan.write(title: "sitOn", name: "앉아", image: #imageLiteral(resourceName: "sitMain"))
            Plan.write(title: "downOn", name: "엎드려", image: #imageLiteral(resourceName: "downMain"))
            Plan.write(title: "waitOn", name: "기다려", image: #imageLiteral(resourceName: "waitMain"))
            Plan.write(title: "comeOff", name: "이리와", image: #imageLiteral(resourceName: "comeMain"))
            Plan.write(title: "handOff", name: "손", image: #imageLiteral(resourceName: "handMain"))
            Plan.write(title: "barkOff", name: "짖어", image: #imageLiteral(resourceName: "barkMain"))
            Plan.write(title: "bangOff", name: "빵야", image: #imageLiteral(resourceName: "bangMain"))
            Plan.write(title: "standOff", name: "일어서", image: #imageLiteral(resourceName: "standMain"))
            Plan.write(title: "rollOff", name: "굴러", image: #imageLiteral(resourceName: "rollMain"))
        }
    }
    
    func setUpNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        { (success, error) in
            if success {
                print("Permission Granted")
            } else {
                print(error?.localizedDescription)
            }
        }
        
        let actionOK = UNNotificationAction(identifier: "actionOK", title: "확인", options: [.foreground])
        let actionCancel = UNNotificationAction(identifier: "actionCancel", title: "취소", options: [.foreground])
        let category = UNNotificationCategory(identifier: "category", actions: [actionOK, actionCancel], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


extension AppDelegate: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func setUpBluetooth() {
        PeripheralInfo.manager = CBCentralManager(delegate: self, queue: nil)
        PeripheralInfo.manager.delegate = self
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
        
        print("Peripheral Name : \(advertisementData[CBAdvertisementDataLocalNameKey]) \(i)")
        i = i + 1
        
        if device?.contains(PeripheralInfo.name) == true {
            PeripheralInfo.manager.stopScan()
            PeripheralInfo.peripheral = peripheral
            PeripheralInfo.peripheral.delegate = self
            PeripheralInfo.manager.connect(peripheral, options: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("DidReadRSSI : \(RSSI)")
        PeripheralInfo.currentRSSI = RSSI
        NotificationCenter.default.post(name: .rssi, object: RSSI)
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        print("peripheralDidUpdateRSSI : \(peripheral.rssi)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        animationView?.play()
        PeripheralInfo.peripheral.discoverServices(nil)
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
                PeripheralInfo.character = cbcharacteristic
                PeripheralInfo.peripheral.setNotifyValue(true, for: cbcharacteristic) //주기적인 업데이트
                
                //send data to BLE
                let value: UInt8 = UInt8(exactly: 7)!
                let data = Data(bytes: [value])
                if PeripheralInfo.peripheral != nil {
                    if let character = PeripheralInfo.character {
                        PeripheralInfo.peripheral.writeValue(data, for: character, type: .withoutResponse)
                    }
                }
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //백그라운드에서 받는 게 가능할까?
        
        PeripheralInfo.peripheral.readRSSI()
        NotificationCenter.default.post(name: .peripheralState, object: nil, userInfo: ["state" : true])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        animationView?.stop()
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 비상! 비상! 🔥"
        content.subtitle = "'복순이'의 위치가 감지되지않습니다."
        content.body = """
'복순이'가 세이프존을 이탈하였습니다.
"""
        content.categoryIdentifier = "category"
        content.sound = UNNotificationSound(named: "dog.mp3")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
        }
        
        NotificationCenter.default.post(name: .peripheralState, object: nil, userInfo: ["state" : false])
        
        if PeripheralInfo.flag {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "actionOK":
            print("Action alert_ok")
        case "actionCancel":
            print("Action alert_ok")
        default:
            break
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}






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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
        
        return true
        
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


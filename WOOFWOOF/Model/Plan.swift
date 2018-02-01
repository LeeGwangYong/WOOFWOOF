//
//  Plan.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 1..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Plan: Object {
    static var realm: Realm {
        return try! Realm()
    }
    
    @objc dynamic var title: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var image: Data = Data()
    @objc dynamic var active: Bool = false
    
    
    override static func primaryKey() -> String? {
        return "title"
    }
    
    static func addToRealm<T: Object>(_ item: T) {
        do {
            try realm.write {
                realm.add(item)
            }
        }
        catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    static func removeFromRealm<T:Object>(_ item: T) {
        do {
            try realm.write {
                realm.delete(item)
            }
        }
        catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    static func removeFromAllRealm() {
        let realm: Realm = try! Realm()
        do {
            try realm.write {
                realm.deleteAll()
            }
        }
        catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    static func write(title: String, name: String, image: UIImage) {
        let inst: Plan = Plan()
        inst.title = title
        inst.name = name
        inst.image = UIImagePNGRepresentation(image)!
        self.addToRealm(inst)
    }
    
    
    
    static func updateRealm(title: String, active: Bool) {
        let items = realm.objects(Plan.self).filter("title == '\(title)'")
        
        let insideRealm = try! Realm()
        try! insideRealm.write {
            if let item = items.first {
                item.active = active
            }
        }
        
    }
}


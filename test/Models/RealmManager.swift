//
//  RealmManager.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmManager {
    static let realm = try! Realm()
    
    class func clearData() {
        realm.deleteAll()
        realm.refresh()
    }
}

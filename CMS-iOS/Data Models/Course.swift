//
//  Course.swift
//  CMS-iOS
//
//  Created by Hridik Punukollu on 13/08/19.
//  Copyright © 2019 Hridik Punukollu. All rights reserved.
//

import UIKit
import RealmSwift

class Course : Object {
    
    @objc dynamic var displayname : String = ""
    @objc dynamic var courseid : Int = 0
    @objc dynamic var enrolled : Bool = false
    @objc dynamic var faculty : String = ""
}

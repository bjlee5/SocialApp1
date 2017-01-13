//
//  User.swift
//  SocialApp1
//
//  Created by MacBook Air on 1/13/17.
//  Copyright © 2017 Lee's. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct User {
    
    var username: String!
    var email: String?
    var proPicURL: String!
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    
    init(snapshot: FIRDataSnapshot) {
        
        key = snapshot.key
        ref = snapshot.ref
        username = (snapshot.value! as! NSDictionary)["username"] as! String
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        uid = (snapshot.value! as! NSDictionary)["uid"] as! String
        proPicURL = (snapshot.value! as! NSDictionary)["proPicURL"] as! String
    }
    
}

//
//  AuthService.swift
//  SocialApp1
//
//  Created by MacBook Air on 1/11/17.
//  Copyright © 2017 Lee's. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftKeychainWrapper

struct AuthService {
    
    var databaseRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    func signUp(username: String, email: String, password: String, pictureData: NSData!) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                
                self.setUserInfo(user: user, username: username, email: email, password: password, pictureData: pictureData)
                
            } else {
                print(error?.localizedDescription)
            }
            
        })
    }
    
    //// 2 - Create Set User Info Function ///
    
    func setUserInfo(user: FIRUser!, username: String, email: String, password: String, pictureData: NSData!) {
        
        let imagePath = "profileImage\(user.uid)/.userPic.jpeg"
        
        let imageRef = storageRef.child(imagePath)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            
            if error == nil {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
                
                if let photoURL = newMetaData!.downloadURL() {
                    changeRequest.photoURL = photoURL
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        
                        self.saveUserInfo(user: user, username: username, password: password)
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                })
                
            } else {
                
                print(error?.localizedDescription)
                
            }
            
        }
        
    }
    
    ///// 3 - Saving the User Info ////////
    
    private func saveUserInfo(user: FIRUser!, username: String, password: String) {
        
        let userInfo = ["email": user.email!, "username": username , "uid": user.uid , "photoURL": String(describing: user.photoURL!)]
        
        let userRef = databaseRef.child("users").child(user.uid)
        
        userRef.setValue(userInfo) { (error, ref) in
            if error == nil {
                print("User info saved successfully")
                self.logIn(email: user.email!, password: password)
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    //// 4 - Logging the User in ////
    
    func logIn(email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user {
                    print("\(user.displayName!) has logged in succesfully")                    
                }
            } else {
                print(error?.localizedDescription)
            }
            
            
        })
        
    }
    
}


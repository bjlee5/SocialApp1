//
//  TestNew.swift
//  SocialApp1
//
//  Created by MacBook Air on 1/13/17.
//  Copyright © 2017 Lee's. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftKeychainWrapper

class TestNew: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }

@IBOutlet weak var userImage: UIImageView!
@IBOutlet weak var userField: UITextField!
@IBOutlet weak var emailField: UITextField!
@IBOutlet weak var passwordField: UITextField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("BRIAN: ID found in keychain")
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImage.image = image
            imageSelected = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func signUp(username: String, email: String, password: String, pictureData: NSData!) {
            if let email = emailField.text, let password = passwordField.text {
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                    if error != nil {
                        print("BRIAN: Unable to authenticate with Firebase using email")
                    } else {
                        print("BRIAN: Successfully authenticated with Firebase")
                        self.setUserInfo(user: user, username: username, email: email, password: password, pictureData: pictureData)

                    }
                })
        }
    
    }
    
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
    
    
    @IBAction func uploadPress(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signUpPress(_ sender: Any) {
        
        let email = emailField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text!
        let username = userField.text!
        let pictureData = UIImageJPEGRepresentation(self.userImage.image!, 0.70)
        
        if finalEmail.isEmpty || password.isEmpty || username.isEmpty || (pictureData?.isEmpty)! {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "MISSING FIELDS", message: "Oops! Looks like you're missing a required field - jackass.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
            
        } else {
            
            self.view.endEditing(true)
            signUp(username: username, email: finalEmail, password: password, pictureData: pictureData as NSData!)
            print("BRIAN: New user successfully created)")
            
        }
        
    }
    
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BRIAN: Segway completed \(keychainResult)")
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }
    
    
}

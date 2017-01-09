//
//  ViewController.swift
//  SocialApp
//
//  Created by MacBook Air on 11/6/16.
//  Copyright © 2016 Lee's. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailTextField: SexyField!
    @IBOutlet weak var passwordTextField: SexyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("BRIAN: ID found in keychain")
            performSegue(withIdentifier: "FeedVC", sender: nil)
        }
        
    }

    @IBAction func facebookButton(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("BRIAN: Unable to Authenticate")
            } else if result?.isCancelled == true {
                print("BRIAN: User canceled Facebook authentication")
            } else {
                print("BRIAN: Succesfully autheticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        
        }

    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("BRIAN: Unable to authenticate with Firebase")
            } else {
                print("BRIAN: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })

    }

    @IBAction func signInBtnPress(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("BRIAN: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("BRIAN: Unable to authenticate with Firebase using email")
                        } else {
                            print("BRIAN: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                                
                            }
                        }
                    })
                }
            })
            
        }
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BRIAN: Segway completed \(keychainResult)")
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }
    
}


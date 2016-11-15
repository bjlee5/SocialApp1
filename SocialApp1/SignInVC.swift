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

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            }
        })

    }

}

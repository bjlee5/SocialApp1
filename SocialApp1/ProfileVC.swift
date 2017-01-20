//
//  ProfileVC.swift
//  SocialApp1
//
//  Created by MacBook Air on 1/13/17.
//  Copyright © 2017 Lee's. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {

    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadUserInfo()
    }
    
    func loadUserInfo(){
        let userRef = databaseRef.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = User(snapshot: snapshot)
            self.username.text = user.username

            
            let imageURL = user.proPicURL!
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.proImage.image = UIImage(data: data)
                        }
                    }
                    
                    
                } else {
                    print(error!.localizedDescription)
                    
                }
                
            })
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    
    @IBAction func backPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

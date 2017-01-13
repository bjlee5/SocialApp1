//
//  NewUserVC.swift
//  SocialApp1
//
//  Created by MacBook Air on 1/9/17.
//  Copyright © 2017 Lee's. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var authService = AuthService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImage.image = image
            imageSelected = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
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
            
            if finalEmail.isEmpty || password.isEmpty || username.isEmpty {
                self.view.endEditing(true)
                let alertController = UIAlertController(title: "MISSING FIELDS", message: "Oops! Looks like you're missing a required field - jackass.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
                
                
            } else {
                
                self.view.endEditing(true)
                authService.signUp(username: username, email: finalEmail, password: password, pictureData: pictureData as NSData!)
                print("BRIAN: New user successfully created)")

            }
            
        }
    

}

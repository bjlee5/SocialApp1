//
//  FeedVC.swift
//  SocialApp1
//
//  Created by MacBook Air on 11/13/16.
//  Copyright © 2016 Lee's. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var postField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    tableView.delegate = self
    tableView.dataSource = self
        
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    
        
    DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
         self.posts = []
        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
            for snap in snapshot {
                print("SNAP: \(snap)")
                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                    let key = snap.key
                    let post = Post(postKey: key, postData: postDict)
                    self.posts.append(post)
                }
            }
        }
     
        self.tableView.reloadData()
        
    })
    
}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString!) {
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
                }
                return cell 
            } else {
                
            return PostCell()
                
            }
        }
    
        //// Posting image to Firebase ////
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func imageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func postBtnPress(_ sender: Any) {
        guard let caption = postField.text, caption != "" else {
            print("BRIAN: Caption must be entered")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("BRIAN: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metdata, error) in
                if error != nil {
                    print("BRIAN: Unable to upload image to Firebase storage")
                } else {
                    print("BRIAN: Successfully printed image to Firebase")
                    let downloadURL = metdata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                }
                    
            }
            
        }
    }
    
}
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = [
        "caption": postField.text!,
        "imageURL": imgUrl,
        "likes": 0            
        ]
        
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        self.tableView.reloadData()

    }
    
    @IBAction func profilePress(_ sender: Any) {
        performSegue(withIdentifier: "ProfileVC", sender: self)
    }
    
    @IBAction func buttonPress(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("BRIAN: ID removed from Key, \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "SignInVC", sender: nil)
    }
}


//
//  PostCell.swift
//  SocialApp1
//
//  Created by MacBook Air on 12/18/16.
//  Copyright © 2016 Lee's. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: CircleView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPost: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    
    let tap = UITapGestureRecognizer(target: self, action: #selector(likesTapped))
    tap.numberOfTapsRequired = 1
    likesImage.addGestureRecognizer(tap)
    likesImage.isUserInteractionEnabled = true 

    }
        
    func configureCell(post: Post, img: UIImage? = nil, proImg: UIImage? = nil) {
        let userRef = likesRef.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
        
        let user = User(snapshot: snapshot)
        self.post = post
        self.likesRef = DataService.ds.REF_CURRENT_USERS.child("likes").child(post.postKey)
        self.postText.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        self.userName.text = user.username
            
            if proImg != nil {
                self.profilePic.image = proImg
            } else {
                    let ref = FIRStorage.storage().reference(forURL: user.proPicURL)
                    ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("BRIAN: Unable to download image from Firebase")
                        } else {
                            print("Image downloaded successfully")
                            if let imgData = data {
                                if let proImg = UIImage(data: imgData) {
                                    self.profilePic.image = proImg
                                    FeedVC.imageCache.setObject(proImg, forKey: user.proPicURL as NSString!)
                                }
                            }
                            
                            
                        }
                    })
                    
                }
            
        if img != nil {
            self.userPost.image = img
        } else {
                let ref = FIRStorage.storage().reference(forURL: post.imageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("BRIAN: Unable to download image from Firebase")
                } else {
                    print("Image downloaded successfully")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.userPost.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString!)
                        }
                    }
                
                
                }
            })
        
        }
    })

    
    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
    if let _ = snapshot.value as? NSNull {
        self.likesImage.image = UIImage(named: "empty-heart")
        } else {
        self.likesImage.image = UIImage(named: "filled-heart")
        }
    })
}

func likesTapped(sender: UIGestureRecognizer) {
    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let _ = snapshot.value as? NSNull {
            self.likesImage.image = UIImage(named: "filled-heart")
            self.post.adjustLikes(addLike: true)
            self.likesRef.setValue(true)
        } else {
            self.likesImage.image = UIImage(named: "empty-heart")
            self.post.adjustLikes(addLike: false)
            self.likesRef.removeValue()
        }
    })
    }

}

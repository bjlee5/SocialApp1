//
//  Post.swift
//  SocialApp1
//
//  Created by MacBook Air on 12/18/16.
//  Copyright © 2016 Lee's. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageURL: String!
    private var _likes: Int!
    private var _profilePicURL: String!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var profilePicURL: String {
        return _profilePicURL
    }
    
    var username: String {
        return _username
    }
    
    init(caption: String, imageURL: String, likes: Int, profilePic: String, username: String) {
        self._caption = caption
        self._imageURL = imageURL
        self._likes = likes
    }
    
    init(postKey: String, postData: Dictionary<String, Any>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageURL = postData["imageURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let profilePicURL = postData["profilePicURL"] as? String {
            self._profilePicURL = profilePicURL
        }
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
    } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }

}

//
//  PostCell.swift
//  SocialApp1
//
//  Created by MacBook Air on 12/18/16.
//  Copyright © 2016 Lee's. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: CircleView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPost: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

//
//  SexyView.swift
//  SocialApp
//
//  Created by MacBook Air on 11/7/16.
//  Copyright © 2016 Lee's. All rights reserved.
//

import UIKit

class SexyView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
    }

}

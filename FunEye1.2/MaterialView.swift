//
//  MaterialView.swift
//  social network for iOS9 with
//
//  Created by Lê Thanh Tùng on 3/18/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class MaterialView: UIView {
    
    override func awakeFromNib() {
        layer.cornerRadius = 4.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.7).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightTextColor().CGColor
    }
    
}
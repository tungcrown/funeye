//
//  ViewCommentCell.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/31/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class ViewCommentCell: UITableViewCell {

    @IBOutlet weak var imgUserAvatar: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCreateTime: UILabel!
    @IBOutlet weak var lblCaption: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgUserAvatar.layer.cornerRadius = imgUserAvatar.frame.width / 2
        imgUserAvatar.clipsToBounds = true
    }
    
    func configureCell(comment: Comment) {
        DataService.instance.downloadAndSetImageFromUrl(comment.userAvatar, imgView: imgUserAvatar, imageCache: ViewCommentVC.imageCache)
        lblUserName.text = comment.userName
        lblCreateTime.text = timeAgoSinceDateString(comment.timeCreate)
        lblCaption.text = comment.caption
    }
}

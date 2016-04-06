//
//  PostCell.swift
//  funeye
//
//  Created by Lê Thanh Tùng on 3/22/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import CoreData

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfileUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTimeCreate: UILabel!
    
    @IBOutlet weak var lblCoutViews: UILabel!
    
    @IBOutlet weak var lblCountLikes: UILabel!
    @IBOutlet weak var lblCountComments: UILabel!
    
    @IBOutlet weak var uiviewVideo: UIView!
    
    @IBOutlet weak var lblCaptionVideo: UILabel!
    
    @IBOutlet weak var imgCommentButton: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    
    var player: AVPlayer!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgProfileUser.layer.cornerRadius = imgProfileUser.frame.width / 2
        imgProfileUser.clipsToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PostCell.tapToVideo(_:)))
        gesture.numberOfTapsRequired = 1
        uiviewVideo.addGestureRecognizer(gesture)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(post: Post, indexPath: Int!) {
        lblCaptionVideo.text = post.caption
        lblUserName.text = post.userName
        lblTimeCreate.text = timeAgoSinceDateString(post.timeCreate)
        lblCoutViews.text = "\(post.views)"
        lblCountLikes.text = "\(post.likes)"
        lblCountComments.text = "\(post.comments)"
        
        //post.SetUiviewVideo(uiviewVideo)
        //load user photo
        DataService.instance.downloadAndSetImageFromUrl(post.userAvatar, imgView: imgProfileUser, imageCache: ViewController.imageCache)
        
        /*
        let urlStr = post.videoUrl
        let video: AVPlayer!
        video = ViewController.videoCache.objectForKey(urlStr) as? AVPlayer
        
        if video != nil {
            player = video
            createPlayerController(player)
            
        } else {
            print("Load post \(post.caption)")
        
            player = DataService.instance.VideoForPath(post.videoPath)
            
            post.videoAVplayer = player
            
            createPlayerController(player)
            
            ViewController.videoCache.setObject(player, forKey: post.videoUrl)
            
            if indexPath == 0 {
                post.playVideo()
            }
        }
        */
 
        if post.isLikePost {
            btnLike.setImage(UIImage(named: "loved"), forState: .Normal)
        } else {
            btnLike.setImage(UIImage(named: "love"), forState: .Normal)
        }
        
    }
    
    func createPlayerController(video: AVPlayer){
        
        
        
        let playerController = AVPlayerViewController()
        
        playerController.view.frame = uiviewVideo.bounds
        playerController.view.sizeToFit()
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        //need remove old subview before add new subview
        /*
        for subview in uiviewVideo.subviews as [UIView] {
            subview.removeFromSuperview()
        }
        */
        uiviewVideo.insertSubview(playerController.view, atIndex: 0)
        playerController.player = video
    }
    
    func tapToVideo(sender: UITapGestureRecognizer) {
        if ((PLAYER_NOW.rate != 0) && (PLAYER_NOW.error == nil)) {
            PLAYER_NOW.pause()
        }else {
            PLAYER_NOW.play()
        }
    }

}

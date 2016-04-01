//
//  Post.swift
//  funeye
//
//  Created by Lê Thanh Tùng on 3/22/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import Foundation
import AVFoundation

class Post: NSObject, NSCoding {
    private var _postId: String!
    
    private var _caption: String!
    private var _videoUrl: String!
    private var _videoAVplayer: AVPlayer!
    private var _videoPath: String!
    private var _timeCreate: String!
    
    private var _userName: String!
    private var _userAvatar: String!
    
    private var _likes: Int!
    private var _comments: Int!
    private var _views: Int!
    private var _shares: Int!
    
    private var Observer: NSObjectProtocol!
    
    var postId: String {
        return _postId
    }
    
    var caption: String {
        return _caption
    }
    
    var videoUrl: String {
        return _videoUrl
    }
    
    var videoAVplayer: AVPlayer {
        get {
            return _videoAVplayer
        }
        set {
            _videoAVplayer = newValue
        }
    }
    
    var videoPath: String {
        get {
            return _videoPath
        }
        
        set {
            _videoPath = newValue
        }
    }
    
    var userName: String {
        return _userName
    }
    
    var userAvatar: String {
        return _userAvatar
    }
    
    var timeCreate: String {
        return _timeCreate
    }
    
    var views: Int {
        return _views
    }
    
    var likes: Int {
        return _likes
    }
    
    var comments: Int {
        return _comments
    }
    
    var shares: Int {
        return _shares
    }
    
    //testing
    init(caption: String, videoUrl: String) {
        self._caption = caption
        self._videoUrl = videoUrl
        
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let id = dictionary["id"] as? String {
            self._postId = id
        }
        
        if let videoUrl = dictionary["videourl"] as? String {
            self._videoUrl = videoUrl
        }
        
        if let caption = dictionary["content"] as? String {
            self._caption = caption
        }
        
        if let likes = dictionary["likesCount"] as? Int {
            self._likes = likes
        }
        
        if let comments = dictionary["comments"] as? Int {
            self._comments = comments
        }
        
        if let views = dictionary["views"] as? Int {
            self._views = views
        }
        /*
        if let shares = dictionary["shares"] as? Int {
            self._shares = shares
        }*/
        
        self._shares = 0
        
        if let timeCreate = dictionary["created"] as? String {
            self._timeCreate = timeCreate
        }
        
        if let arrayUser = dictionary["creator"] as? Dictionary<String, AnyObject> {
            if let userName = arrayUser["fullName"] as? String {
                self._userName = userName
            }
            
            if let userAvatar = arrayUser["avatar"] as? String {
                self._userAvatar = userAvatar
            }
            
        }
    }
    
    override init() {
        
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self._postId = aDecoder.decodeObjectForKey("postId") as? String
        self._caption = aDecoder.decodeObjectForKey("caption") as? String
        self._videoUrl = aDecoder.decodeObjectForKey("videoUrl") as? String
        self._videoPath = aDecoder.decodeObjectForKey("videoPath") as? String
        self._timeCreate = aDecoder.decodeObjectForKey("timeCreate") as? String
        self._userName = aDecoder.decodeObjectForKey("userName") as? String
        self._userAvatar = aDecoder.decodeObjectForKey("userAvatar") as? String
        self._likes = aDecoder.decodeObjectForKey("likes") as? Int
        self._comments = aDecoder.decodeObjectForKey("comments") as? Int
        self._views = aDecoder.decodeObjectForKey("views") as? Int
        self._shares = aDecoder.decodeObjectForKey("shares") as? Int
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._postId, forKey: "postId")
        aCoder.encodeObject(self._caption, forKey: "caption")
        aCoder.encodeObject(self._videoUrl, forKey: "videoUrl")
        aCoder.encodeObject(self._videoPath, forKey: "videoPath")
        aCoder.encodeObject(self._timeCreate, forKey: "timeCreate")
        aCoder.encodeObject(self._userName, forKey: "userName")
        aCoder.encodeObject(self._userAvatar, forKey: "userAvatar")
        aCoder.encodeObject(self._likes, forKey: "likes")
        aCoder.encodeObject(self._comments, forKey: "comments")
        aCoder.encodeObject(self._views, forKey: "views")
        aCoder.encodeObject(self._shares, forKey: "shares")
    }
    
    func playVideo() {
        if _videoAVplayer != nil {
            _videoAVplayer.play()
            loopVideo(self._videoAVplayer)
        }else {
            print("nil video")
        }
    }
    
    func pauseVideo() {
        if self._videoAVplayer != nil {
            self._videoAVplayer.pause()
            
            if self.Observer != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self.Observer)
            }
        }
    }
    
    private func loopVideo(videoPlayer: AVPlayer) {
        self.Observer = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            videoPlayer.seekToTime(kCMTimeZero)
            videoPlayer.play()
            
            print("loop video :\(videoPlayer)")
        }
    }
}

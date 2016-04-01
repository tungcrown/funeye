//
//  DataService.swift
//  MyHood App
//
//  Created by Lê Thanh Tùng on 3/15/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import AVFoundation
import Foundation
import Alamofire

class DataService {
    static let instance = DataService()
    
    let KEY_POSTS = "posts"
    
    private var _loadingPost = [Post]()
    
    var loadingPost: [Post] {
        return _loadingPost
    }
    
    func savePosts(post: Post) {
        
        let videoUrl = post.videoUrl
        var localPath: NSURL?
        var pathComponent: String?
        Alamofire.download(.GET, videoUrl, destination: { (temporaryURL, response) in
            let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            //let pathComponent = response.suggestedFilename
            pathComponent = "video\(NSDate.timeIntervalSinceReferenceDate()).mp4"
            
            localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
            
            return localPath!
        }).response { (request, response, data, error) in
            
            if localPath != nil {
                
                print("Downloaded file to \(localPath!)")
                post.videoPath = pathComponent!

                
                self._loadingPost.append(post)
                
                let postsData = NSKeyedArchiver.archivedDataWithRootObject(self._loadingPost)
                NSUserDefaults.standardUserDefaults().setObject(postsData, forKey: self.KEY_POSTS)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.loadPosts()
            }
            
            if error != nil {
                print("error download: \(error.debugDescription)")
            }
            
        }

    }
    /*
    func saveImage(imageUrl: String) {
        var localPath: NSURL?
        var pathComponent: String?
        
        Alamofire.download(.GET, imageUrl, destination: { (temporaryURL, response) in
            let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            //let pathComponent = response.suggestedFilename
            pathComponent = "avatar\(NSDate.timeIntervalSinceReferenceDate()).jpg"
            
            localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
            
            return localPath!
        }).response { (request, response, data, error) in
            
            if localPath != nil {
                print("Downloaded user avatar to \(localPath!)")
                
                
                self._loadingPost.append(post)
                
                let postsData = NSKeyedArchiver.archivedDataWithRootObject(self._loadingPost)
                NSUserDefaults.standardUserDefaults().setObject(postsData, forKey: self.KEY_POSTS)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.loadPosts()
            }
            
            if error != nil {
                print("error download: \(error.debugDescription)")
            }
            
        }
    }*/
    
    func loadPosts() {
        if let postsData = NSUserDefaults.standardUserDefaults().objectForKey(KEY_POSTS) as? NSData {
            if let postsArray = NSKeyedUnarchiver.unarchiveObjectWithData(postsData) as? [Post] {
                _loadingPost = postsArray
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "PostsLoaded", object: nil))
    }
    
    func addPost(post: Post) {
        //_loadingPost.append(post)
        
        savePosts(post)
        loadPosts()
    }
    
    func VideoForPath(path: String) -> AVPlayer? {
        let fullPath = documentPathForFilename(path)
        let nsUrl = NSURL(string: fullPath)
        
        return AVPlayer(URL: nsUrl!)
    }
 
    
    func documentPathForFilename(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fullPath = paths[0] as NSString
        
        return "file://" + fullPath.stringByAppendingPathComponent(name)
    }
    
    func downloadAndSetImageFromUrl(url: String, imgView: UIImageView, imageCache: NSCache) {
        let img = imageCache.objectForKey(url) as? UIImage
        if img != nil {
            imgView.image = img
        } else {
            Alamofire.request(.GET, url).validate(contentType: ["image/*"]).response(completionHandler: { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> Void in
            
                if error == nil {
                    let img = UIImage(data: data!)!
                    imgView.image = img
                    //save cache
                    imageCache.setObject(img, forKey: url)
                }
            })
        }
    }
}
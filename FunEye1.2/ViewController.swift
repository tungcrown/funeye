//
//  ViewController.swift
//  funeye
//
//  Created by Lê Thanh Tùng on 3/21/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uivTabar: UIView!
    
    var posts = [Post]()
    
    static var imageCache = NSCache()
    static var videoCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
  
        DataService.instance.loadPosts()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onPostsLoaded), name: "PostsLoaded", object: nil)
        
        posts = DataService.instance.loadingPost
        
        //download data
        let NewfeedsUrl = URL_GET_NEW_FEED
        print("NewfeedsUrl \(NewfeedsUrl)")
        let url = NSURL(string: NewfeedsUrl)!
        Alamofire.request(.GET, url).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    print("load new data")
                    for json in jsons {
                        let post = Post(dictionary: json)
                        self.checkExistAndAddPost(post)
                    }
                }
            } else {
                print(response)
            }
        }
    
    }
    
    func checkExistAndAddPost(post: Post) {
        var checkExistPost = false
        for postCheck in posts {
            if postCheck.videoUrl == post.videoUrl {
                checkExistPost = true
            }
        }
        
        if checkExistPost == false {
            DataService.instance.addPost(post)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            /*
            let tapCommentIcon = UITapGestureRecognizer(target: self, action: #selector(self.viewComment(_:)))
            tapCommentIcon.numberOfTapsRequired = 1
            imgCommentButton.addGestureRecognizer(tapCommentIcon)
            */
            
            cell.configureCell(post, indexPath: indexPath.row)
            cell.imgCommentButton.tag = indexPath.row
            cell.imgCommentButton.addTarget(self, action: #selector(ViewController.viewComment(_:)), forControlEvents: .TouchUpInside)
            
            cell.btnLike.tag = indexPath.row
            cell.btnLike.addTarget(self, action: #selector(ViewController.likePost(_:)), forControlEvents: .TouchUpInside)
            
            return cell
            
        } else {
            return PostCell()
        }
    }
    
    var timer = NSTimer()
    var checkTimerLoadVideo = true;
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y > 0 {
            uivTabar.hidden = true
        }else {
            uivTabar.hidden = false
        }
        
        
        if checkTimerLoadVideo {
            checkTimerLoadVideo = false
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: false)
        }
    }
    
    func update() {
        checkTimerLoadVideo = true
        print("1.5s after scroll cells")
        let cell = tableView.visibleCells
        let indexPath: Int!
        if cell.count == 3 {
            indexPath = tableView.indexPathForCell(cell[1])!.row
        } else if cell.count == 2 {
            let maxYcell = cell[0].frame.maxY
            let minY = tableView.bounds.minY
            let maxY = tableView.bounds.maxY
            let rangeScreen = maxY - minY
            
            if maxYcell >= maxY - rangeScreen/2 {
                indexPath = tableView.indexPathForCell(cell[0])!.row
            } else {
                indexPath = tableView.indexPathForCell(cell[1])!.row
            }
            
        } else if cell.count == 1 {
            indexPath = tableView.indexPathForCell(cell[0])!.row
        } else {
            indexPath = tableView.indexPathForCell(cell[0])!.row
        }
        
        playVideoNow(indexPath)
    }
    
    var videoPlayNow = 0
    
    func playVideoNow(indexPath: Int) {
        print("videoPlayNow \(indexPath)")
        if videoPlayNow != indexPath{
            for post in posts {
                post.pauseVideo()
            }
            
            posts[indexPath].playVideo()
            videoPlayNow = indexPath
        } else {
            print("agian")
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        posts[indexPath.row].pauseVideo()
    }
 
    func onPostsLoaded() {
        print("done load posts")
        posts = DataService.instance.loadingPost
        tableView.reloadData()
    }
    @IBAction func btnCameraACTION(sender: UIButton) {
        pauseAllVideo()
    }
    func pauseAllVideo() {
        for post in posts {
            post.pauseVideo()
        }
    }
    
    func viewComment(sender: UIButton) {
        pauseAllVideo()
        let commentUrl = posts[sender.tag].postId
        self.performSegueWithIdentifier("ViewCommentVC", sender: commentUrl)
    }
    
    func likePost(sender: UITapGestureRecognizer) {
        print("like post")
        
        Alamofire.request(.PUT, "http://funeye.net:8000/api/articles/2/like?access_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InNlY3JldC5hbmRvYW5AZ21haWwuY29tIiwicm9sZSI6InVzZXIiLCJpYXQiOjE0NTg3MDI4NzN9._ebdOP1QHLtaVgsdfzLoZatqk-landvYDPCprcKH-4DMwE").response(completionHandler: { (nsrequest: NSURLRequest?, response: NSHTTPURLResponse?, nsData: NSData?, error: NSError?) in
            
            print(response!.statusCode)
            
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewCommentVC" {
            if let viewCommentVC = segue.destinationViewController as? ViewCommentVC {
                if let data = sender as? String {
                    viewCommentVC.post_id = data
                }
            }
        }
    }
}


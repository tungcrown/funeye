//
//  ViewController.swift
//  funeye
//
//  Created by Lê Thanh Tùng on 3/21/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SocketIOClientSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uivTabar: UIView!
    
    var posts = [Post]()
    var videoPlayNow: Int!
    
    static var imageCache = NSCache()
    static var videoCache = NSCache()
    
    private var Observer: NSObjectProtocol!
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://funeye.net:8080")!, options: [.Log(false), .ForcePolling(true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataAccess()
        
        tableView.delegate = self
        tableView.dataSource = self
  
        DataService.instance.loadPosts()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onPostsLoaded), name: "PostsLoaded", object: nil)
        
        posts = DataService.instance.loadingPost
        
        loadDataNewfeeds()
        
        socket.on("viewed") {data, ack in
            if let postId = data as? [Dictionary<String, AnyObject>] {
                if let str = postId[0]["id"] as? Int {
                    for (index, post) in self.posts.enumerate() {
                        if Int(post.postId) ==  str {
                            print("caption view \(post.caption)")
                            if let view = postId[0]["views"] as? Int {
                                self.posts[index].views = view
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
 
            }
        }
        socket.connect()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        videoPlayNow = -1
        update()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        pauseAllVideo()
    }
    
    func loadDataNewfeeds() {
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
                        //self.checkExistAndAddPost(post)
                        DataService.instance.addPost(post)
                    }
                }
            } else {
                print(response)
            }
        }
    }
    
    
    func getDataAccess() {
        if NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY) != nil {
            ACCESS_TOKEN = NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY)! as! String
        } else {
            ACCESS_TOKEN = ""
        }
        
        if NSUserDefaults.standardUserDefaults().valueForKey(USER_ID_KEY) != nil {
            USER_ID = NSUserDefaults.standardUserDefaults().valueForKey(USER_ID_KEY)! as! String
        } else {
            USER_ID = ""
        }
    }
    /*
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
    }*/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
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
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print("fir \(indexPath.row)")
        
        let nsIndexPath = NSIndexPath(forRow: videoPlayNow, inSection: 0)
        
        if let cell = tableView.cellForRowAtIndexPath(nsIndexPath) {
            print("11111")
        } else {
            print("11112")
            pauseAllVideo()
        }
        /*if videoPlayNow == indexPath.row {
            pauseAllVideo()
        }*/
    }
    
    var timer = NSTimer()
    var checkTimerLoadVideo = true;
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        /*
        if velocity.y > 0 {
            uivTabar.hidden = true
        }else {
            uivTabar.hidden = false
        }
        */
        
        if checkTimerLoadVideo {
            checkTimerLoadVideo = false
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: false)
        }
    }
    
    func update() {
        if let cells = tableView.visibleCells as? [UITableViewCell] {
            
            checkTimerLoadVideo = true
            var cell: UITableViewCell
            
            let indexPath: Int!
            if cells.count == 3 {
                indexPath = tableView.indexPathForCell(cells[1])!.row
                cell = cells[1]
            } else if cells.count == 2 {
                let maxYcell = cells[0].frame.maxY
                let minY = tableView.bounds.minY
                let maxY = tableView.bounds.maxY
                let rangeScreen = maxY - minY
                
                if maxYcell >= maxY - rangeScreen/2 {
                    indexPath = tableView.indexPathForCell(cells[0])!.row
                    cell = cells[0]
                } else {
                    indexPath = tableView.indexPathForCell(cells[1])!.row
                    cell = cells[1]
                }
                
            } else if cells.count == 1 {
                indexPath = tableView.indexPathForCell(cells[0])!.row
                cell = cells[0]
            } else {
                indexPath = tableView.indexPathForCell(cells[0])!.row
                cell = cells[0]
            }
            playVideoNow(cell,indexPath: indexPath)
        }
    }
    
    func playVideoNow(cell: UITableViewCell, indexPath: Int) {
        print("videoPlayNow \(indexPath)")
        if videoPlayNow != indexPath{
            pauseAllVideo()
            playVideo(cell, post: posts[indexPath])
            videoPlayNow = indexPath
        } else {
            print("agian")
        }
    }
    
    func playVideo(cell: UITableViewCell, post: Post) {
        let videoPath = post.videoPath
        let fullPath = DataService.instance.documentPathForFilename(videoPath)
        let nsUrl = NSURL(string: fullPath)
        
        PLAYER_NOW =  AVPlayer(URL: nsUrl!)
        
        let witdthPlayVideo = self.view.frame.size.width
        let uiviewVideo = UIView(frame: CGRectMake(0, 55, witdthPlayVideo, witdthPlayVideo))
        uiviewVideo.backgroundColor = UIColor.darkGrayColor()
        uiviewVideo.tag = 99
        
        cell.addSubview(uiviewVideo)
        
        let playerController = AVPlayerViewController()
        
        playerController.view.frame = uiviewVideo.bounds
        playerController.view.sizeToFit()
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        uiviewVideo.insertSubview(playerController.view, atIndex: 0)
        playerController.player = PLAYER_NOW
        
        PLAYER_NOW.play()
        loopVideo(PLAYER_NOW, post: post)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapToVideo(_:)))
        gesture.numberOfTapsRequired = 1
        uiviewVideo.addGestureRecognizer(gesture)
    }
    
    private func loopVideo(videoPlayer: AVPlayer, post: Post) {
        Observer = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            videoPlayer.seekToTime(kCMTimeZero)
            videoPlayer.play()
            
            print("loop video \(URL_PUT_VIEW_POST(post.postId)) :\(videoPlayer)")
            Alamofire.request(.PUT, URL_PUT_VIEW_POST(post.postId))
        }
    }
 
    func onPostsLoaded() {
        print("done load posts")
        posts = DataService.instance.loadingPost
        tableView.reloadData()
    }
    @IBAction func btnCameraACTION(sender: UIButton) {
        //pauseAllVideo()
    }
    func pauseAllVideo() {
        tableView.viewWithTag(99)?.removeFromSuperview()
        PLAYER_NOW = AVPlayer()
        if Observer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(Observer)
        }
    }
    
    func viewComment(sender: UIButton) {
        //pauseAllVideo()
        let commentUrl = posts[sender.tag].postId
        self.performSegueWithIdentifier("ViewCommentVC", sender: commentUrl)
    }
    
    func likePost(sender: UIButton) {
        print("like post")
        let post = posts[sender.tag]
        let postId = post.postId
        post.isLikePost = !post.isLikePost
        
        if post.isLikePost {
            sender.setImage(UIImage(named: "loved"), forState: .Normal)
        } else {
            sender.setImage(UIImage(named: "love"), forState: .Normal)
        }
        
        Alamofire.request(.PUT, URL_PUT_LIKE_POST(postId, isFollow: post.isLikePost))
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
    
    func tapToVideo(sender: UITapGestureRecognizer) {
        if ((PLAYER_NOW.rate != 0) && (PLAYER_NOW.error == nil)) {
            PLAYER_NOW.pause()
        }else {
            PLAYER_NOW.play()
        }
    }
}


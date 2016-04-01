//
//  ViewCommentVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ViewCommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var uivInputComment: UIView!
    @IBOutlet weak var txtInputComment: UITextField!
    @IBOutlet weak var btnPostComment: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    static var imageCache = NSCache()
    
    var post_id: String!
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        print(post_id)
        
        //download data
        //let commentUrl = URL_GET_COMMENT
        let commentUrl = createUrlCallComment(post_id)
        let url = NSURL(string: commentUrl)!
        Alamofire.request(.GET, url).responseJSON { response in
            
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    for json in jsons {
                        let comment = Comment(dictionary: json)
                        self.comments.append(comment)
                    }
                    self.commentTableView.reloadData()
                }
            } else {
                    print("comment nil")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewCommentVC.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewCommentVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height+8, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect = view.frame
        viewRect.size.height -= keyboardSize.height
        if CGRectContainsPoint(viewRect, uivInputComment.frame.origin) {
            let scrollPoint = CGPointMake(0, uivInputComment.frame.origin.y - keyboardSize.height)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {

        if let cell = tableView.dequeueReusableCellWithIdentifier("ViewCommentCell") as? ViewCommentCell {
            cell.configureCell(comments[indexPath.row])
            return cell
        } else {
            return ViewCommentCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        view.endEditing(true)
    }
    
    @IBAction func backNewfeeds(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnPostCommentACTION(sender: UIButton) {
        
    }
}

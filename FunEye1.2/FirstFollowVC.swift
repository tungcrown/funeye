//
//  FirstFollowVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class FirstFollowVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var uitableViewFollow: UITableView!
    
    @IBOutlet weak var uitableViewTopic: UITableView!
    
    var friends = [Friend]()
    
    var user_id: String!
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uitableViewFollow.delegate = self
        uitableViewFollow.dataSource = self
        
        if user_id != nil {
            print(user_id)
        }
        
        print("ACCESS_TOKEN \(ACCESS_TOKEN)")
        
        /*
        // Do any additional setup after loading the view.
        let friend = Friend(name: "Tung Crown", id: "1", avatarUrl: "https://sourceava.s3-ap-southeast-1.amazonaws.com/1.jpg", message: "Facebook")
        friends.append(friend)
        
        let friend1 = Friend(name: "Tung Crown 2", id: "1", avatarUrl: "https://sourceava.s3-ap-southeast-1.amazonaws.com/1.jpg", message: "Facebook")
        friends.append(friend1)
        
        let friend2 = Friend(name: "Tung Crown 3", id: "1", avatarUrl: "https://sourceava.s3-ap-southeast-1.amazonaws.com/1.jpg", message: "Facebook")
        friends.append(friend2)*/
        let url: String!
        url = URL_GET_FRIEND_FOLLOW
        
        print("ACCESS_TOKEN \(url)")
        
        Alamofire.request(.GET, url).responseJSON { response in
            print("res \(response)")
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                print("res \(res)")
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    for json in jsons {
                        print("json fiends \(json)")
                        let friend = Friend(dictionary: json)
                        self.friends.append(friend)
                    }
                    self.uitableViewFollow.reloadData()
                }
            } else {
                print("Load Friend Follow Nil")
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("FirstFollowCell") as? FirstFollowCell {
            
                let friend = friends[indexPath.row]
                cell.configureCell(friend)
                return cell
        }else {
            return FirstFollowCell()
        }
    }
}

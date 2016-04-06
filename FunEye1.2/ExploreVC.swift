//
//  ExploreVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ExploreVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tabeviewCategories: UITableView!
    
    var topics = [Dictionary<String, AnyObject?>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabeviewCategories.delegate = self
        tabeviewCategories.dataSource = self
        
        
        
        print(URL_GET_CATEGORIES)
        //URL_GET_CATEGORIES = "http://funeye.net:8000/api/categoryInfo?access_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InR1bmdjcm93bjIwMTZAZ21haWwuY29tIiwiaWF0IjoxNDU5NDgzNzU0fQ.UUNbN_yLZktV1wZKv7umlGMT8q_b10sOEFyBSS5hZHM"
        Alamofire.request(.GET, URL_GET_CATEGORIES).responseJSON { response in
            if response.result.error != nil {
                print("error load follow \(response.result.error)")
            } else {
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                        for json in jsons {
                            if let id = json["_id"] as? Int {
                                let topic = ["_id": json["_id"], "image" : "https://graph.facebook.com/246809342331820/picture", "name": json["name"], "backgroundColor": json["color"]]
                                self.topics.append(topic)
                            }
                        }
                        self.tabeviewCategories.reloadData()
                    }
                } else {
                    print("Load topic follow \(response)")
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ExploreCell") as? ExploreCell {

            let topic = topics[indexPath.row]
            cell.configureCell(topic)
            cell.btnChooseCategory.tag = indexPath.row
            cell.btnChooseCategory.addTarget(self, action: #selector(self.btnChooseCategoryACTION(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        
        } else {
            return ExploreCell()
        }
    }
    
    @IBAction func btnMenuQuickACTION(sender: UIButton) {
        let tag = sender.tag
        var cateId: String!
        
        if tag == 1 {
            cateId = "New"
        } else if tag == 2 {
            cateId = "Hot"
        } else if tag == 3 {
            cateId = "Hit"
        }
        
        performSegueWithIdentifier("ShowExploreVC", sender: cateId)
    }
    
    func btnChooseCategoryACTION(sender: UIButton) {
        let tag = sender.tag
        if let cateId = topics[tag]["name"] as? String {
            performSegueWithIdentifier("ShowExploreVC", sender: cateId)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowExploreVC" {
            if let showExploreVC = segue.destinationViewController as? ShowExploreVC {
                if let dataSender = sender as? String {
                    showExploreVC.data = dataSender
                }
            }
        }
    }

    
}
//
//  ShowExploreVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class ShowExploreVC: UIViewController {
    
    @IBOutlet weak var lblTitleCategory: UILabel!
    
    var data: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if data != nil {
            lblTitleCategory.text = data
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToExploreVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}

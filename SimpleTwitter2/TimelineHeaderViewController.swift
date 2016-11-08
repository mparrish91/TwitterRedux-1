//
//  TimelineHeaderViewController.swift
//  SimpleTwitter2
//
//  Created by Jonathan Cheng on 11/7/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class TimelineHeaderViewController: UIViewController {
        
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    let bannerImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3
        profileImageView.contentMode = .scaleAspectFill

        // Configure Profile Banner
        bannerImageView.frame = headerView.frame
        bannerImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bannerImageView.contentMode = .scaleAspectFill
        headerView.addSubview(bannerImageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

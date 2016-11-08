//
//  ProfileViewController.swift
//  SimpleTwitter2
//
//  Created by Jonathan Cheng on 11/7/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AFNetworking

class ProfileViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    let bannerImageView = UIImageView()

    private let kFollowers = "FOLLOWERS"
    private let kFollowing = "FOLLOWING"
    
    // Model
    var userID: String? {
        didSet {
            if let userID = userID {
                TwitterSessionManager.sharedInstance.fetchUser(userID: userID, completion: { (response: Any?) in
                    if let response = (response as? NSArray)?[0] {
                        let user = User(with: response as! NSDictionary)
                        self.user = user
                        self.populateUserDetails()
                    }
                }) { (error: Error?) in
                        print("Error \(error?.localizedDescription)")
                }
            }
        }
    }
    // user may be set directly, for instance to User.currentUser before views are setup
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = "Profile"
        
        // Configure Profile icon
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
       
        // Load timeline into content view
        let storyboard = UIStoryboard.init(name: kIDMainStoryboard, bundle: nil)
        let contentVC = storyboard.instantiateViewController(withIdentifier: kIDTweetsViewController) as! TweetsViewController
        if let userID = userID {
            contentVC.userID = userID
        }
        addChildViewController(contentVC)
        contentVC.view.frame = contentView.bounds
        contentView.addSubview(contentVC.view)
        contentVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentVC.didMove(toParentViewController: self)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateUserDetails() {
        // Fill in user profile
        if let user = user {
            followingLabel.text = "\(user.followingCount) " + kFollowing
            followersLabel.sizeToFit()
            followersLabel.text = "\(user.followersCount) " + kFollowers
            followersLabel.sizeToFit()
            
            if let url = user.profileURL {
                profileImageView.setImageWith(url)
            }
            if let url = user.headerURL {
                bannerImageView.setImageWith(url)
            }
        }
    }
}

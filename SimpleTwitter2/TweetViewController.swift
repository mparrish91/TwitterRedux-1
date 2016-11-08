//
//  TweetViewController.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/30/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol TweetViewContollerDatasource: class {
    func tweet() -> Tweet?
}

class TweetViewController: UIViewController, ReplyButtonDatasource, FavouriteButtonDatasource, RetweetButtonDatasource, TweetComposeViewControllerDatasource, RetweetButtonDelegate, FavouriteButtonDelegate {

    // Model uses protocol TweetViewContollerDatasource
    weak var datasource: TweetViewContollerDatasource?
    
    // Views
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var retweetButton: RetweetButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favouriteCountLabel: UILabel!
    @IBOutlet weak var favouriteButton: FavouriteButton!
    @IBOutlet weak var replyButton: ReplyButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Tweet"

        retweetButton.datasource = self
        retweetButton.delegate = self
        replyButton.datasource = self
        favouriteButton.datasource = self
        favouriteButton.delegate = self

        configureViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureViews() {
        if let tweet = datasource?.tweet() {
            if let text = tweet.text {
                tweetTextLabel.text = text
            }
            favouriteButton.isSelected = tweet.favourited
            retweetButton.isSelected = tweet.retweeted
            retweetCountLabel.text = String(tweet.retweetCount)
            favouriteCountLabel.text = String(tweet.favourtiesCount)

            // Configure user contents
            if let user = tweet.user {
                usernameLabel.text = user.name
                if let url = user.profileURL {
                    profileImageView.setImageWith(url)
                }
                if let screenname = user.screenname {
                    screennameLabel.text = "@\(screenname)"
                }
            }
            
            if let createdAt = tweet.createdAtString {
                timestampLabel.text = createdAt
            }
        }
    }
    
//MARK- protocols
    
    func replyToStatusID(_ sender: UIViewController) -> String? {
        return getTweetIDString()
    }
    
    func replyToUsername(_ sender: UIViewController) -> String? {
        if let screenname = datasource?.tweet()?.user?.screenname {
            return "@" + screenname
        }
        else { return nil }
    }
    
    func tweetID(_ sender: UIButton) -> String? {
        return getTweetIDString()
    }
 
    func parentVC(_ sender: UIButton) -> UIViewController {
        return self
    }
    
    func updateRetweetedStatus(_ sender: UIButton, to status: Bool) {
        if let tweet = datasource?.tweet() {
            tweet.retweeted = status
            if status {
                tweet.retweetCount += 1
            } else { tweet.retweetCount -= 1 }
        }
        configureViews()
    }
    
    func updateFavouritedStatus(_ sender: UIButton, to status: Bool) {
        if let tweet = datasource?.tweet() {
            tweet.favourited = status
            if status {
                tweet.favourtiesCount += 1
            } else { tweet.favourtiesCount -= 1 }
        }
        configureViews()
    }
    
    // Helper method
    func getTweetIDString() -> String? {
        if let tweet = datasource?.tweet() {
            return tweet.idString
        }
        return nil
    }
    
}

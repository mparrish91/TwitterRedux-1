//
//  TweetsViewController.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AFNetworking

let kTweetsComposeNavigationControllerName = "TweetNavigationController"
let notificationNewTweet = Notification.Name("newTweet")
let notificationUserInfoTweetKey = "tweet"

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetViewContollerDatasource, TweetTableViewCellDelegate {
    
    private let kTweetsTableViewCellIdentifier = "TweetTableViewCell"
    private let kFollowers = "FOLLOWERS"
    private let kFollowing = "FOLLOWING"

    var userID: String?
    var tweets: [Tweet] = []
    var currentSelectedIndex = -1
    let refreshControl = UIRefreshControl()
    var timelineSelector = #selector(fetchTimeline)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the model and views
        // If no usedID string is provided, then default to loading authenticated user's timeline
        timelineSelector = userID != nil ? #selector(fetchUserTimeline) : #selector(fetchTimeline)
        
        navigationItem.title = "Timeline"
        // Initialize a pull to refresh UIRefreshControl
        refreshControl.addTarget(self, action: timelineSelector, for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.style = UITableViewStyle.grouped
        
        perform(timelineSelector)
        
        // Setup notification for new tweets (add to timeline without fetching from Network)
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTweet(notification:)), name: notificationNewTweet, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destinationVC = segue.destination as? TweetViewController {
            destinationVC.datasource = self
        }
    }
    
//MARK- Model
    func fetchTimeline() {
        TwitterSessionManager.sharedInstance.fetchTimeline(completion: { (response) in
            if let response = response {
                self.loadTableWithTweets(response)
            }
        }) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserTimeline() {
        if let userID = userID {
            TwitterSessionManager.sharedInstance.fetchTimeline(for: userID, completion: { (response) in
                if let response = response {
                    self.loadTableWithTweets(response)
                }
            }) { (error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadTableWithTweets(_ data: [Tweet]) {
        tweets = data
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
// MARK: - tableView methods

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTweetsTableViewCellIdentifier, for: indexPath) as! TweetTableViewCell
        cell.delegate = self
        
        // Set model
        let tweet = tweets[indexPath.row]
        
        // Configure cell
        if let ID = tweet.user?.ID {
            cell.userID = ID
        }
        
        if let text = tweet.text {
            cell.tweetTextLabel.text = text
        }

        // Configure user contents
        if let user = tweet.user {
            cell.usernameLabel.text = user.name
            if let url = user.profileURL {
                cell.profileImageView.setImageWith(url)
            }
        }
        
        if let timeSince = tweet.timeSinceNowString {
            cell.timestampLabel.text = timeSince
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
  
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 225.00
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let storyboard = UIStoryboard.init(name: kIDContainerStoryboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: kIDTimelineHeaderViewController) as! TimelineHeaderViewController
        vc.view.frame = CGRect(x: 0, y: 0, width: 375, height: 225)

        if let user = user {
            vc.followingLabel.text = "\(user.followingCount) " + kFollowing
            vc.followersLabel.sizeToFit()
            vc.followersLabel.text = "\(user.followersCount) " + kFollowers
            vc.followersLabel.sizeToFit()
            
            if let url = user.profileURL {
                vc.profileImageView.setImageWith(url)
            }
            if let url = user.headerURL {
                vc.bannerImageView.setImageWith(url)
            }
        }
        
        return vc.view
    }*/
    
// Mark: Protocol methods
    func tweet() -> Tweet? {
        if currentSelectedIndex >= 0
        {
            return tweets[currentSelectedIndex]
        }
        return nil
    }
    
// MARK: Actions
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        TwitterSessionManager.sharedInstance.logout()
    }
    
    @IBAction func composeButtonTapped(_ sender: UIBarButtonItem) {
        TweetComposeViewController.present(from: self)
    }
    
// Mark: Notifications
    func addNewTweet(notification: NSNotification) {
        let tweet = notification.userInfo?["tweet"] as! Tweet
        tweets.insert(tweet, at: 0)
        tableView.reloadData()
    }
    
// MARK TweetTableViewCell methods
    func tappedOnProfile(with userID: String?) {
        let storyboard = UIStoryboard.init(name: kIDContainerStoryboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: kIDProfileViewController) as! ProfileViewController
        vc.userID = userID
        
        if let navVC = navigationController {
            navVC.pushViewController(vc, animated: true)
        }

    }
}

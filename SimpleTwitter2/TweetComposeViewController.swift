//
//  TweetComposeViewController.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/31/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol TweetComposeViewControllerDatasource: class {
    // The ID of tweet/status you are replying to
    func replyToStatusID(_ sender: UIViewController)-> String?
    func replyToUsername(_ sender: UIViewController) -> String?
}

class TweetComposeViewController: UIViewController, UITextViewDelegate {
    
    weak var datasource: TweetComposeViewControllerDatasource?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var wordCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let user = User.currentUser {
            usernameLabel.text = user.name
            screennameLabel.text = "@" + user.screenname!
            profileImageView.setImageWith(user.profileURL!)
        }
        
        tweetTextView.delegate = self
        tweetTextView.textAlignment = .left
        tweetTextView.becomeFirstResponder()
        
        if let referencedUsername = datasource?.replyToUsername(self) {
            tweetTextView.text = referencedUsername + " "
        } else {
            tweetTextView.text = ""
        }
        updateWordCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateWordCount() {
        wordCountLabel.text = String(tweetTextView.text.characters.count)
    }
    
// Present this VC from another VC
    class func present(from: UIViewController) {
        let storyboard = UIStoryboard.init(name: kIDMainStoryboard, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: kTweetsComposeNavigationControllerName) as! UINavigationController
        
        if let composeVC = destinationVC.topViewController as? TweetComposeViewController {
            // Hook datasource if implements protocol TweetComposeViewControllerDatasource
            if let datasource = from as? TweetComposeViewControllerDatasource {
                print("Hooked compose VC datasource")
                composeVC.datasource = datasource
            }
            from.present(destinationVC, animated: true)
        }
    }
    
// MARK- Action methods
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true) { }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        if let text = tweetTextView.text {
            let completionClosure = { (response: Any?) in
                //Notify a new tweet has been posted
                let tweet = Tweet(dictionary: response as! NSDictionary)
                NotificationCenter.default.post(name: notificationNewTweet, object: nil, userInfo: [notificationUserInfoTweetKey: tweet])

                self.dismiss(animated: true, completion: { })
            }
            let errorClosure = { (error: Error) in
                print("Error: \(error.localizedDescription)")
                self.dismiss(animated: true, completion: { })
            }
            
            // Reply to tweet (i.e. a datasource exists)
            if let datasource = datasource {
                if let replyToStatusID = datasource.replyToStatusID(self) {
                        TwitterSessionManager.sharedInstance.postReply(text: text, to: replyToStatusID, completion: { (response: Any?) in
                            print("Tweeted reply!")
                            completionClosure(response)
                            }, failure: { (error: Error) in
                                errorClosure(error)
                        })
                } else {
                    print("Error replying to status: there is no ID from datasource.  Send Failed.")
                }
            }
            // Normal tweet ((i.e. NO datasource exists)
            else {
                TwitterSessionManager.sharedInstance.postTweet(text: text, completion: { (response: Any?) in
                    print("Tweeted!")
                    completionClosure(response)
                }) { (error:Error) in
                    errorClosure(error)
                }
            }
        }
    }
    
// MARK Delegate methods
    
    func textViewDidChange(_ textView: UITextView) {
        updateWordCount()
    }
}

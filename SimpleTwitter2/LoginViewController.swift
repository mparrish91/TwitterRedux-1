//
//  ViewController.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/28/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let kIDMainStoryboard = "Main"
let kIDContainerStoryboard = "Container"
let kIDTwitterContainerViewController = "TwitterContainerViewController"
let kIDTimelineNavigationController = "TimelineNavigationController"
let kIDTweetsViewController = "TweetsViewController"
let kIDHamburgerViewController = "HamburgerMenuViewController"
let kIDProfileNavigationController = "ProfileNavigationController"
let kIDProfileViewController = "ProfileViewController"
let kIDTimelineHeaderViewController = "TimelineHeaderViewController"

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func getRootVCAfterLogin() -> UIViewController {
        // Completion code upon successful login
        let storyboard = UIStoryboard.init(name: kIDContainerStoryboard, bundle: nil)
        let rootVC = storyboard.instantiateViewController(withIdentifier: kIDTwitterContainerViewController)
        return rootVC
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton, forEvent event: UIEvent) {
        // Login to Twitter
        // Start OAuth session manager & initiate token request
        TwitterSessionManager.sharedInstance.login(completion: {            
            self.present(LoginViewController.getRootVCAfterLogin(), animated: true, completion: { })
        }) { (error) in
                if let error = error { print("Error: \(error.localizedDescription)") }
        }
    }
}


//
//  TwitterContainerViewController.swift
//  SimpleTwitter2
//
//  Created by Jonathan Cheng on 11/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

private let debug = true

class TwitterContainerViewController: UIViewController, HamburgerMenuViewContollerDatasource, HamburgerMenuViewControllerDelegate {

    // Gesture vars
    // Used to monitor direction: left direction = false; right direction = true
    private var panXDirection = false
    // Startpoint; used to anchor cumulative translation.x calculations
    private var originalTrailingMargin: CGFloat!

    private let menuTrailingMarginMinimum: CGFloat = 50.00
    private let menuSlideAnimationDuration = 0.25
    // Setup offscreen (to the left) margin
    private var menuTrailingMarginMaximum: CGFloat! {
        get{ return view.frame.width }
    }
    
    // Models vars: parallel arrays
    private let menuContents = ["Profile", "Timeline", "Mentions"]
    private var contentViewControllers: [UIViewController]! = []
    private var currentContentVC: UIViewController?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Add pan gestures for showing/hiding menu
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHamburgerMenu(_:)))
        view.addGestureRecognizer(pan)
        // Start with a closed menu
        menuViewTrailingConstraint.constant = menuTrailingMarginMaximum

        var storyboard: UIStoryboard
        var contentVC: UIViewController
        // Setup content view contollers
        // Profile
        storyboard = UIStoryboard.init(name: kIDContainerStoryboard, bundle: nil)
        contentVC = storyboard.instantiateViewController(withIdentifier: kIDProfileNavigationController)
        contentViewControllers.append(contentVC)
        
        if let contentVC = contentVC as? UINavigationController {
            (contentVC.topViewController as! ProfileViewController).user = User.currentUser
        }
        
        // Timeline
        storyboard = UIStoryboard.init(name: kIDMainStoryboard, bundle: nil)
        contentVC = storyboard.instantiateViewController(withIdentifier: kIDTimelineNavigationController)
        contentViewControllers.append(contentVC)

        // Mentions
        // Use empty VC for now
        contentVC = UIViewController(nibName: nil, bundle: nil)
        contentVC.view.backgroundColor = UIColor.green
        contentViewControllers.append(contentVC)
        
        // Add main VC (timeline)
        addChildVCToContentView(contentViewControllers[1])
        
        // Add hamburger menu
        storyboard = UIStoryboard.init(name: kIDContainerStoryboard, bundle: nil)
        let menu = storyboard.instantiateViewController(withIdentifier: kIDHamburgerViewController) as! HamburgerMenuViewController
        addChildViewController(menu)
        // Set menu options
        menu.datasource = self
        menu.delegate = self
        // Set menu view
        menu.view.frame = menuView.bounds
        menuView.addSubview(menu.view)
        menu.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menu.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addChildVCToContentView(_ vc: UIViewController)
    {
        // If content VC remove it
        if let oldChildViewController = currentContentVC {
            oldChildViewController.willMove(toParentViewController: nil)
            oldChildViewController.view.removeFromSuperview()
            oldChildViewController.removeFromParentViewController()
        }
        
        // Add new content vc
        addChildViewController(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.didMove(toParentViewController: self)
        currentContentVC = vc
    }
    
// MARK - gesture methods
    func panHamburgerMenu(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let velocity = panGestureRecognizer.velocity(in: view)
//        let location = panGestureRecognizer.location(in: view)
        let translation = panGestureRecognizer.translation(in: view)
        
        switch panGestureRecognizer.state {
        case .began:
            if debug { print("Pan began") }
            // Anchor to the beginning margin (and add cumulative translation in change state)
            originalTrailingMargin = menuViewTrailingConstraint.constant
        case .ended:
            if debug { print("Pan ended") }
            animateHamburgerMenu(open: panXDirection)
            
        case .cancelled:
            if debug { print("Pan cancelled") }
        case .changed:
            if debug { print("Pan changed") }
            if debug { print("moving \(velocity.x > 0 ? "moving right": "moving left")") }
            
            // X > 0 = moving right; X < 0 = moving left
            panXDirection = velocity.x > 0 ? true : false
            
            // Update menu trailing (right) margin constraint
            // Moving left increases margin (and translation.x is negative) and vice versa
            // Cannot move beyond trailing margin max & min
            let newTrailingMargin = originalTrailingMargin - translation.x
            if (newTrailingMargin < menuTrailingMarginMaximum) && (newTrailingMargin > menuTrailingMarginMinimum) {
                menuViewTrailingConstraint.constant = newTrailingMargin
            }
        case .failed:
            if debug { print("Pan failed") }
        case .possible:
            if debug { print("Pan possible") }
        }
    }
    
    func animateHamburgerMenu(open: Bool) {
        UIView.animate(withDuration: menuSlideAnimationDuration) { 
            self.menuViewTrailingConstraint.constant = open ? self.menuTrailingMarginMinimum : self.menuTrailingMarginMaximum
            self.view.layoutIfNeeded()
        }
    }
    
// Mark- Hamburger Menu methods
    func menu() -> NSArray {
        return menuContents as NSArray
    }
    
    func didSelectRow(_ row: Int) {
        addChildVCToContentView(contentViewControllers[row])
        
        // Close menu
        animateHamburgerMenu(open: false)
    }
    
}

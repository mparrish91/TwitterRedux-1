//
//  RetweetButton.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/31/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol RetweetButtonDatasource: class {
    func tweetID(_ sender: UIButton) -> String?
}

protocol RetweetButtonDelegate: class {
    func updateRetweetedStatus(_ sender: UIButton, to status: Bool)
}

class RetweetButton: UIButton {
    let deselectedImage = UIImage(imageLiteralResourceName: "retweet-action")
    let selectedImage = UIImage(imageLiteralResourceName: "retweet-action-on")
    private let actionType = "Retweeted"
    
    weak var datasource: RetweetButtonDatasource?
    weak var delegate: RetweetButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setImage(deselectedImage, for: .normal)
        setImage(selectedImage, for: .selected)
        addTarget(self, action: #selector(tapped), for: UIControlEvents.touchUpInside)
    }

    func tapped() {
        //isSelected = retweeted
        //!isSelected = not retweeted
        isSelected = !isSelected

        // Tweet is set so can go ahead and tweet or untweet
        if let tweetID = datasource?.tweetID(self) {
            if isSelected {
                TwitterSessionManager.sharedInstance.postRetweet(id: tweetID, completion: { (response:Any?) in
                    print(self.actionType)
                    self.delegate?.updateRetweetedStatus(self, to: self.isSelected)
                    }, failure: { (error: Error) in
                        print("\(self.actionType) Error: \(error)")
                })
            } else {
                TwitterSessionManager.sharedInstance.postUnRetweet(id: tweetID, completion: { (response: Any?) in
                    print("Un-\(self.actionType)")
                    self.delegate?.updateRetweetedStatus(self, to: self.isSelected)
                    }, failure: { (error: Error) in
                        print("\(self.actionType) Error: \(error)")
                })
            }
        } else {
            print("\(actionType) failed, tweet ID not set")
        }
    }
}

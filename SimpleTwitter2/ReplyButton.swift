//
//  ReplyButton.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/31/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol ReplyButtonDatasource: class {
    func parentVC(_ sender: UIButton) -> UIViewController
}

class ReplyButton: UIButton {

    private let deselectedImage = UIImage(imageLiteralResourceName: "reply-action_0")
    private let actionType = "Replied"
    weak var datasource: ReplyButtonDatasource?
    
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
        addTarget(self, action: #selector(tapped), for: UIControlEvents.touchUpInside)
    }
    
    func tapped() {
        TweetComposeViewController.present(from: (datasource?.parentVC(self))!)
    }
}

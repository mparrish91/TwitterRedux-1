//
//  FavouriteButton.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/31/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit


// TODO: havent' checked status update responses to verify
// also, tweet status is not updated in current model (i.e. after retweet, model becomes stale without refresh)

protocol FavouriteButtonDatasource: class {
    func tweetID(_ sender: UIButton) -> String?
}
protocol FavouriteButtonDelegate: class {
    func updateFavouritedStatus(_ sender: UIButton, to status: Bool)
}

class FavouriteButton: UIButton {

    private let deselectedImage = UIImage(imageLiteralResourceName: "like-action")
    private let selectedImage = UIImage(imageLiteralResourceName: "like-action-on")
    private let actionType = "Favourited"
    
    weak var datasource: FavouriteButtonDatasource?
    weak var delegate: FavouriteButtonDelegate?
    
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
        //isSelected = favourited
        //!isSelected = not favourited
        isSelected = !isSelected
        
        // Tweet is set so can go ahead and tweet or untweet
        if let tweetID = datasource?.tweetID(self) {
            if isSelected {
                TwitterSessionManager.sharedInstance.postFavourite(id: tweetID, completion: { (response:Any?) in
                    print(self.actionType)
                    self.delegate?.updateFavouritedStatus(self, to: self.isSelected)
                    }, failure: { (error: Error) in
                        print("\(self.actionType) Error: \(error)")
                })
            } else {
                TwitterSessionManager.sharedInstance.postUnFavourite(id: tweetID, completion: { (response:Any?) in
                    print("Un-\(self.actionType)")
                    self.delegate?.updateFavouritedStatus(self, to: self.isSelected)
                    }, failure: { (error: Error) in
                        print("\(self.actionType) Error: \(error)")
                })
            }
        } else {
            print("\(self.actionType) failed, tweet ID not set")
        }
    }
}

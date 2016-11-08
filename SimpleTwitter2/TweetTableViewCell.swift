//
//  TweetTableViewCell.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol TweetTableViewCellDelegate: class {
    func tappedOnProfile(with userID: String?)
}

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    var userID: String?
    
    weak var delegate: TweetTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedImageView(_:)))
        profileImageView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func tappedImageView(_ tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.state == .ended {
            delegate?.tappedOnProfile(with: userID)
        }
    }
}

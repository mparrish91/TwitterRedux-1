//
//  Tweet.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

let kTweetTextKey = "text"
let kTweetCreatedAtKey = "created_at"
let kTweetRetweetCountKey = "retweet_count"
let kTweetFavoritesCountKey = "favorite_count"
let kTweetUserKey = "user"
let kTweetDateFormat = "EEE MMM d HH:mm:ss Z y"
let kTweetIDKey = "id"
let kTweetIDStringKey = "id_str"
let kTweetFavouritedKey = "favorited"
let kTweetRetweetedKey = "retweeted"

class Tweet: NSObject {
    var text: String?
    var createdAt: Date?
    var retweetCount: Int = -1
    var favourtiesCount: Int = -1
    var user: User?
//    var replyTo: String?
    var id: CLong = -1
    var idString: String?
    var favourited = false
    var retweeted = false
    
    init(dictionary: NSDictionary) {
        text = dictionary[kTweetTextKey] as? String
        
        if let createdAtString = dictionary[kTweetCreatedAtKey] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = kTweetDateFormat
            createdAt = formatter.date(from: createdAtString)
        }
        
        if let count = dictionary[kTweetRetweetCountKey] as? Int {
            retweetCount = count
        }
        if let count = dictionary[kTweetFavoritesCountKey] as? Int {
            favourtiesCount = count
        }
        
        if let userDictionary = dictionary[kTweetUserKey] as? NSDictionary {
            user = User(with: userDictionary)
        }
        
        if let count = dictionary[kTweetIDKey] as? CLong {
            id = count
        }
        
        if let string = dictionary[kTweetIDStringKey] as? String {
            idString = string
        }
        
        if let fav = dictionary[kTweetFavouritedKey] as? Bool {
            favourited = fav
        }
        
        if let retw = dictionary[kTweetRetweetedKey] as? Bool {
            retweeted = retw
        }

    }
    
    var timeSinceNowString: String? {
        if let timestamp = createdAt {
            let componentsFormatter = DateComponentsFormatter()
            componentsFormatter.unitsStyle = .abbreviated
            componentsFormatter.allowedUnits = [.day, .hour, .minute]
            
            return componentsFormatter.string(from: -timestamp.timeIntervalSinceNow)
        }
        return nil
    }
    
    var createdAtString: String? {
        if let createdAt = createdAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy, hh:mm"
            return formatter.string(from: createdAt)
        }
        return nil
    }
    
}

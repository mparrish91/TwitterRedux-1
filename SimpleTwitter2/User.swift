//
//  User.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/29/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

let kUserNameKey = "name"
let kUserScreennameKey = "screen_name"
let kUserProfileImageURLKey = "profile_image_url_https"
let kUserDescriptionKey = "description"
let kUserDefaultsCurrentUserDataKey = "SimpleTwitterCurrentUserData"
let kUserBannerImageURLKey = "profile_banner_url"
let kUserNumberFollowersKey = "followers_count"
let kUserNumberFollowKey = "friends_count"
let kUserIDKey = "id_str"
class User: NSObject {
    var name: String?
    var screenname: String?
    var profileURL: URL?
    var headerURL: URL?
    var userDescription: String?
    var userDictionary: NSDictionary
    var followersCount: Int
    var followingCount: Int
    var ID: String?
    
    init(with dictionary: NSDictionary) {
        userDictionary = dictionary
        
        name = dictionary[kUserNameKey] as? String
        
        screenname = dictionary[kUserScreennameKey] as? String
        
        if let profileURLString = dictionary[kUserProfileImageURLKey] as? String {
            profileURL = URL(string: profileURLString)
        }
        
        if let headerURLString = dictionary[kUserBannerImageURLKey] as? String {
            headerURL = URL(string: headerURLString)
        }
        
        userDescription = dictionary[kUserDescriptionKey] as? String
        
        followingCount = dictionary[kUserNumberFollowKey] as! Int
        followersCount = dictionary[kUserNumberFollowersKey] as! Int
        
        if let id = dictionary[kUserIDKey] as? String {
            ID = id
        }
    }
    
    class var currentUser: User? {
        get {
            let defaults = UserDefaults.standard
            
            if let userData = defaults.object(forKey: kUserDefaultsCurrentUserDataKey) as? Data {
                let dictionary = try! JSONSerialization.jsonObject(with: userData, options: [])
                let user = User(with: dictionary as! NSDictionary)
                return user
            }
            
            return nil
        }
        set(user) {
            let defaults = UserDefaults.standard
            
            // Unwrap user and save serialized (dict) info to defaults
            if let user = user {
                // Save serialized dictionary of user
                let data = try! JSONSerialization.data(withJSONObject: user.userDictionary, options: [])
                defaults.set(data, forKey: kUserDefaultsCurrentUserDataKey)
                print("Serialized current user and saving to defaults")
            }
            else {
                defaults.removeObject(forKey: kUserDefaultsCurrentUserDataKey)
            }
            
            defaults.synchronize()
        }
    }
}

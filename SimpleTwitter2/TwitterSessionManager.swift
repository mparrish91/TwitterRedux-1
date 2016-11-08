//
//  TwitterSessionManager.swift
//  SimpleTwitter
//
//  Created by Jonathan Cheng on 10/28/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

private let kTwitterSMConsumerKey = "lVH02Era6z8NcuhdK8v0e2yRF"
private let kTwitterSMConsumerSecret = "Iw8uVCIG4XYbxFFEsayU4RwhB51GZl29k7wt8YgachzKo13031"

private let kTwitterSMRequestMethodGet = "GET"
private let kTwitterSMRequestMethodPost = "POST"
private let kTwitterSMTwitterURLAddress = "https://api.twitter.com/"
private let kTwitterSMRequestTokenURLPath = "oauth/request_token"
private let kTwitterSMAuthorizeURLAddress = "https://api.twitter.com/oauth/authorize?oauth_token="
private let kTwitterSMCallbackURLAddress = "SimpleTwitter://oauth"
private let kTwitterSMAccessTokenPath = "oauth/access_token"

private let kTwitterSMResourcePathVerifyCredential = "1.1/account/verify_credentials.json"
private let kTwitterSMResourcePathStatusHomeTimeline = "1.1/statuses/home_timeline.json"
private let kTwitterSMResourcePathRetweet = "1.1/statuses/retweet/:id.json"
private let kTwitterSMResourcePathRetweetIDPlaceholder = ":id"
private let kTwitterSMResourcePathUnRetweet = "1.1/statuses/unretweet/:id.json"
private let kTwitterSMResourcePathFavourite = "1.1/favorites/create.json"
private let kTwitterSMResourcePathUnFavourite = "1.1/favorites/destroy.json"
private let kTwitterSMParameterIDKey = "id"
private let kTwitterSMParameterReplyToIDKey = "in_reply_to_status_id"

private let kTwitterSMResourcePathTweet = "1.1/statuses/update.json"
private let kTwitterSMParameterTweetKey = "status"
private let kTwitterSMHomeTimelineParameters = ["count": "20"]

private let kTwitterSMResourcePathUserLookup = "1.1/users/lookup.json"
private let kTwitterSMUserLookupKey = "user_id"

private let kTwitterSMResourcePathUserTimeline = "1.1/statuses/user_timeline.json"

let notificationLogout = Notification.Name("logoutNotification")

class TwitterSessionManager: NSObject {
    static let sharedInstance = TwitterSessionManager()

    var completionOnLogin: (() -> ())?
    var failureOnLogin: ((Error?) -> ())?
    
    // Instance
    private let sessionManager = BDBOAuth1SessionManager(baseURL: URL(string: kTwitterSMTwitterURLAddress), consumerKey: kTwitterSMConsumerKey, consumerSecret: kTwitterSMConsumerSecret)!
    
    private override init() {
        super.init()
    }
    
    func logout() {
        User.currentUser = nil
        sessionManager.deauthorize()
        
        
        NotificationCenter.default.post(name: notificationLogout, object: nil)
    }
    
    func login(completion onLogin: @escaping() -> (), failure: @escaping(Error?) -> ()) {
        TwitterSessionManager.sharedInstance.sessionManager.deauthorize()
        sessionManager.deauthorize()
        sessionManager.fetchRequestToken(withPath: kTwitterSMRequestTokenURLPath, method: kTwitterSMRequestMethodGet, callbackURL: URL(string: kTwitterSMCallbackURLAddress), scope: nil, success: { (requestToken) in
            //completion code
            print("Request token recieved")
            // Save completion/failure blocks to be executed on login completion
            self.completionOnLogin = onLogin
            self.failureOnLogin = failure
            
            if let requestToken = requestToken {
                let url = URL(string: kTwitterSMAuthorizeURLAddress + requestToken.token!)!
                
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("Verifying platform credentials")
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func completeLogin(with url:URL!) {
        let credential = BDBOAuth1Credential(queryString: url.query)!
        
        sessionManager.fetchAccessToken(withPath: kTwitterSMAccessTokenPath, method: kTwitterSMRequestMethodPost, requestToken: credential, success: { (accessToken) in
            // completion code
            print("Access token received, login complete")
            
            // Get current user account, save it and continue with login completion closure "completionOnLogin"
            self.fetchCurrentAccount(completion: { (user: User) in
                // Save current user account
                User.currentUser = user
                self.completionOnLogin?()
                }, failure: { (error: Error) in
                    self.failureOnLogin?(error)
            })
            }, failure: { (error) in
                self.failureOnLogin?(error)
        })
    }
    
    func fetchCurrentAccount(completion: @escaping(User) -> (), failure: @escaping(Error) -> ()) {
        sessionManager.get(kTwitterSMResourcePathVerifyCredential, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            if let userDictionary = response as? NSDictionary {
                completion(User(with: userDictionary))
            }
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                //error code
                failure(error)
        })
    }
    
    func fetchTimeline(completion: @escaping([Tweet]?) -> (), failure: @escaping(Error?) -> ()) {
        sessionManager.get(kTwitterSMResourcePathStatusHomeTimeline, parameters: kTwitterSMHomeTimelineParameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            // completion code
            print("Timeline retrieved")
        
            if let response = response as? NSArray {
                // Construct array of tweets
                var tweets = [Tweet]()
                print("Fetched \(response.count) tweets in timeline")
                for aResponse in response {
                    let tweet = Tweet(dictionary: aResponse as! NSDictionary)
                    tweets.append(tweet)
                }
                completion(tweets)
            }
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                //error code
                failure(error)
        })
    }

    func fetchTimeline(for userID: String, completion: @escaping([Tweet]?) -> (), failure: @escaping(Error?) -> ()) {
        sessionManager.get(kTwitterSMResourcePathUserTimeline, parameters: [kTwitterSMUserLookupKey: userID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            // completion code
            print("Timeline retrieved")
            
            if let response = response as? NSArray {
                // Construct array of tweets
                var tweets = [Tweet]()
                print("Fetched \(response.count) tweets in timeline")
                for aResponse in response {
                    let tweet = Tweet(dictionary: aResponse as! NSDictionary)
                    tweets.append(tweet)
                }
                completion(tweets)
            }
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                //error code
                failure(error)
        })
    }

    
    func fetchUser(userID: String, completion: @escaping(Any?) -> (), failure: @escaping(Error?) -> ()) {
        sessionManager.get(kTwitterSMResourcePathUserLookup, parameters: [kTwitterSMUserLookupKey: userID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            print("User fetched")
            completion(response)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func postRetweet(id: String, completion: @escaping(Any?) -> (), failure: @escaping(Error) -> ()) {
        let resourcePath = kTwitterSMResourcePathRetweet.replacingOccurrences(of: kTwitterSMResourcePathRetweetIDPlaceholder, with: id)
        sessionManager.post(resourcePath, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            completion(response)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func postUnRetweet(id: String, completion: @escaping(Any?) -> (), failure: @escaping(Error) -> ()) {
        let resourcePath = kTwitterSMResourcePathUnRetweet.replacingOccurrences(of: kTwitterSMResourcePathRetweetIDPlaceholder, with: id)
        sessionManager.post(resourcePath, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            completion(response)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func postFavourite(id: String, completion: @escaping(Any?) -> (), failure: @escaping(Error) -> ()) {
        sessionManager.post(kTwitterSMResourcePathFavourite, parameters: [kTwitterSMParameterIDKey: id], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            completion(response)
        }) { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        }
    
    }
    
    func postUnFavourite(id: String, completion: @escaping(Any?) -> (), failure: @escaping(Error) -> ()) {
        sessionManager.post(kTwitterSMResourcePathUnFavourite, parameters: [kTwitterSMParameterIDKey: id], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            completion(response)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func postTweet(text: String, completion: @escaping(Any?) -> (), failure: @escaping(Error) -> ()) {
        let parameter = [kTwitterSMParameterTweetKey: text]
        sessionManager.post(kTwitterSMResourcePathTweet, parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            completion(response)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func postReply(text: String, to TweetID: String, completion: @escaping(Any?) -> (), failure: @escaping(Error) -> ()) {
        let parameter = [kTwitterSMParameterTweetKey: text, kTwitterSMParameterReplyToIDKey: TweetID]
        sessionManager.post(kTwitterSMResourcePathTweet, parameters: parameter, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            completion(response)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }

    }
}

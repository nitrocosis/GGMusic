//
//  SpotifyClient.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

class SpotifyClient: NSObject, SPTSessionManagerDelegate {
    
    let SpotifyClientID = "e59bc86bd19545b38a185d3beefa34de"
    let SpotifyRedirectURL = URL(string: "gg-music://callback")!
    
    var loginSuccess: (() -> Void)? = nil
    var loginFailed: (() -> Void)? = nil
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        
        configuration.tokenSwapURL = URL(string: "https://gg-music.herokuapp.com/api/token")
        configuration.tokenRefreshURL = URL(string: "https://gg-music.herokuapp.com/api/refresh_token")
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("Login success", session)
        loginSuccess?()
    }
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Login failed", error)
        loginFailed?()
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("Session renewed", session)
    }
    
    //MARK: Shared
    class func sharedInstance() -> SpotifyClient {
        struct Singleton {
            static var shared = SpotifyClient()
        }
        
        return Singleton.shared
    }
}

//
//  SpotifyClient.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

class SpotifyClient: NSObject, SPTSessionManagerDelegate {
    
    var loginSuccess: (() -> Void)? = nil
    var loginFailed: (() -> Void)? = nil
    
    lazy var configuration: SPTConfiguration = {
        
        let configuration = SPTConfiguration(clientID: SpotifyConstants.Configuration.ClientId, redirectURL: SpotifyConstants.Configuration.RedirectURL)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        
        configuration.tokenSwapURL = SpotifyConstants.Configuration.TokenSwapURL
        configuration.tokenRefreshURL = SpotifyConstants.Configuration.TokenRefreshURL
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
    
    func login(success: @escaping () -> Void, failed: @escaping () -> Void) {
        self.loginSuccess = success
        self.loginFailed = failed
        
        let requestedScopes: SPTScope = [
            .playlistReadPrivate,
            .playlistReadCollaborative,
            .playlistModifyPublic,
            .playlistModifyPrivate,
            .userLibraryRead,
            .userLibraryModify,
            .userReadPlaybackState,
            .userModifyPlaybackState,
            .userReadCurrentlyPlaying,
            .appRemoteControl
        ]
        
        sessionManager.initiateSession(with: requestedScopes, options: .default)
    }
    
    func taskForGetPlaylists(completion: @escaping (_ result: SpotifyPlaylists?, _ error: NSError?) -> Void) {
        var request = URLRequest(url: SpotifyConstants.Endpoints.GetPlaylists)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(sessionManager.session!.accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.sendError("Something went wrong, please try again", "taskForGetPlaylists", completion)
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.sendError("Something went wrong, please try again", "taskForGetPlaylists", completion)
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                let result = try! decoder.decode(SpotifyPlaylists.self, from: data!)
                completion(result, nil)
            }
            else{
                self.sendErrorForHttpStatusCode(httpStatusCode, "taskForGetPlaylists", completion)
            }
        }
        task.resume()
    }
    
    //MARK: Shared
    class func sharedInstance() -> SpotifyClient {
        struct Singleton {
            static var shared = SpotifyClient()
        }
        
        return Singleton.shared
    }
}

//
//  SpotifyClientSupport.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

extension SpotifyClient {
    
    func isSpotifyAppInstalled() -> Bool {
        return sessionManager.isSpotifyAppInstalled
    }
    
    func isLoggedIn() -> Bool {
        return sessionManager.session != nil
    }
        
    func sendError(_ errorString: String, _ domain: String, _ completion: @escaping (_ result: SpotifyPlaylists?, _ error: NSError?) -> Void) {
        let userInfo = [NSLocalizedDescriptionKey : errorString]
        completion(nil, NSError(domain: domain, code: 1, userInfo: userInfo))
    }
    
    func sendErrorForHttpStatusCode(_ httpStatusCode: Int, _ domain: String, _ completion: @escaping (_ result: SpotifyPlaylists?, _ error: NSError?) -> Void) {
        switch(httpStatusCode) {
        case 400: // BadRequest
            sendError("Bad request, please try again", domain, completion)
        case 401: // Invalid Credentials
            sendError("Invalid Credentials, please try again", domain, completion)
        case 403: // Invalid Credentials
            sendError("Unauthorized, please try again", domain, completion)
        case 410: // URL Changed
            sendError("URL changed, please try again", domain, completion)
        case 500: // URL Changed
            sendError("Server error, please try again later", domain, completion)
        default:
            sendError("Something went wrong, please try again", domain, completion)
        }
    }
}

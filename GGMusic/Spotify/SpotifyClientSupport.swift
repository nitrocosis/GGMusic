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
}

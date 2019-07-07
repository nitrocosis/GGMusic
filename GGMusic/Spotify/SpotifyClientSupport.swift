//
//  SpotifyClientSupport.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

extension SpotifyClient {
    
    func login() {
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

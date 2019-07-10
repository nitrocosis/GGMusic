//
//  SpotifyConstants.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

extension SpotifyClient {
    
    struct SpotifyConstants {

        struct Configuration {
            static let ClientId = "e59bc86bd19545b38a185d3beefa34de"
            static let RedirectURL = URL(string: "gg-music://callback")!
            static let TokenSwapURL = URL(string: "https://gg-music.herokuapp.com/api/token")!
            static let TokenRefreshURL = URL(string: "https://gg-music.herokuapp.com/api/refresh_token")!
        }
        
        struct Endpoints {
            static let GetPlaylists = URL(string: "https://api.spotify.com/v1/me/playlists")!
        }
    }
}

//
//  Playlist.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/9/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

struct SpotifyPlaylist: Codable {
    
    let name: String
    let images: [SpotifyImage]
}

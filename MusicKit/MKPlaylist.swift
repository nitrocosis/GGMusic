//
//  MKPlaylist.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/16/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

struct MKPlaylistResponse: Codable {
    
    let data: [MKPlaylist]
}

struct MKPlaylist: Codable {
    
    let id: String
    let attributes: MKPlaylistAttributes?
}

struct MKPlaylistAttributes: Codable {
    
    let name: String
    let artwork: MKArtwork?
}

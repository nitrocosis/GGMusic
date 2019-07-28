//
//  MKTrack.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/18/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

struct MKTrackResponse: Codable {
    
    let data: [MKTrack]
}

struct MKAddTracksToPlaylistRequest: Codable {
    
    let data: [MKTrack]
}

struct MKTrackSearchResponse: Codable {
    
    let results: MKTrackSearchResults?
}

struct MKTrackSearchResults: Codable {
    
    let songs: MKTrackResponse?
}

struct MKTrack: Codable {
    
    let id: String
    let type: String
    let attributes: MKTrackAttributes?
}

struct MKTrackAttributes: Codable {
    
    let name: String
    let artistName: String?
    let albumName: String?
    let artwork: MKArtwork?
    let playParams: MKTrackPlayParams?
}

struct MKTrackPlayParams: Codable {
    
    let catalogId: String?
}

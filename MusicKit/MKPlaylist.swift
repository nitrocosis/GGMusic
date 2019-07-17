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
    let attributes: MKPlaylistAttributes
}

struct MKPlaylistAttributes: Codable {
    
    let name: String
    let artwork: MKPlaylistArtwork
}

struct MKPlaylistArtwork: Codable {

    let width: Int?
    let height: Int?
    let url: String
}

extension MKPlaylistArtwork {
    
    // Returns the fully qualified url to retrieve the image.
    // Use this instead of MKPlaylistArtwork.url.
    func getUrl() -> String {
        var imageUrl = url
        if (width != nil) {
            imageUrl = imageUrl.replacingOccurrences(of: "{w}", with: "\(width!)")
        }
        if (height != nil) {
            imageUrl = imageUrl.replacingOccurrences(of: "{h}", with: "\(height!)")
        }
        return imageUrl
    }
}

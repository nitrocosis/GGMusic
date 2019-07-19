//
//  MKArtwork.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/18/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

struct MKArtwork: Codable {
    
    let width: Int?
    let height: Int?
    let url: String
}

extension MKArtwork {
    
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

//
//  MKPlaylistClientSupport.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/16/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

extension MKPlaylistClient {
    
    func getPlaylists(completion: @escaping (_ playlistResponse: MKPlaylistResponse?, _ error: NSError?) -> Void) {
        taskForGetPlaylists() { (playlistResponse, error) in
            if let error = error {
                completion(nil, error as NSError)
            } else {
                completion(playlistResponse as? MKPlaylistResponse, nil)
            }
        }
    }
    
    func postPlaylist(name: String, completion: @escaping (_ playlistResponse: MKPlaylistResponse?, _ error: NSError?) -> Void) {
        taskForPostPlaylist(playlistName: name) { (playlistResponse, error) in
            if let error = error {
                completion(nil, error as NSError)
            } else {
                completion(playlistResponse as? MKPlaylistResponse, nil)
            }
        }
    }
}

//
//  MKTrackClientSupport.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/18/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

extension MKTrackClient {
    
    func getTracks(playlistId: String, completion: @escaping (_ trackResponse: MKTrackResponse?, _ error: NSError?) -> Void) {
        taskForGetTracks(playlistId: playlistId) { (trackResponse, error) in
            if let error = error {
                completion(nil, error as NSError)
            } else {
                completion(trackResponse as? MKTrackResponse, nil)
            }
        }
    }
    
    func addTracks(playlistId: String, tracks: [MKTrack], completion: @escaping (_ trackResponse: AnyObject?, _ error: NSError?) -> Void) {
        taskForPostTracks(playlistId: playlistId, tracks: tracks) { (addTrackResponse, error) in
            if let error = error {
                completion(nil, error as NSError)
            } else {
                completion(addTrackResponse, nil)
            }
        }
    }
}

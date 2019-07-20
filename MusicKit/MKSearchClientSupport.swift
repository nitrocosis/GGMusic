//
//  MKSearchClientSupport.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/20/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

extension MKSearchClient {
    
    func searchTracks(term: String, completion: @escaping (_ searchResponse: MKTrackResponse?, _ error: NSError?) -> Void) {
        taskForGetTracks(term: term) { (searchResponse, error) in
            if let error = error {
                completion(nil, error as NSError)
            } else {
                let response = searchResponse as? MKTrackSearchResponse
                let trackResponse = response?.results.songs
                completion(trackResponse, nil)
            }
        }
    }
}

//
//  MKTrackClient.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/18/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

class MKTrackClient: MKClient {
    
    static let shared = MKTrackClient()
    
    func taskForGetTracks(playlistId: String, completion: @escaping (_ trackResponse: AnyObject?, _ error: NSError?) -> Void) {
        
        let request = createURLRequest("\(MKConstants.Playlist)\(playlistId)\(MKConstants.Tracks)")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.sendError("Something went wrong, please try again", "taskForGetTracks", completion)
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.sendError("Something went wrong, please try again", "taskForGetTracks", completion)
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                let result = try! decoder.decode(MKTrackResponse.self, from: data!)
                completion(result as AnyObject, nil)
            }
            else{
                self.sendErrorForHttpStatusCode(httpStatusCode, "taskForGetTracks", completion)
            }
        }
        
        task.resume()
    }
}

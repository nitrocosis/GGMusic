//
//  MKPlaylistClient.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/16/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

class MKPlaylistClient: MKClient {
    
    static let shared = MKPlaylistClient()
    
    func taskForGetPlaylists(completion: @escaping (_ playlistResponse: AnyObject?, _ error: NSError?) -> Void) {

        let request = createURLRequest("\(MKConstants.Playlist)?\(MKConstants.Limit)=100")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.sendError("Something went wrong, please try again", "taskForGetPlaylists", completion)
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.sendError("Something went wrong, please try again", "taskForGetPlaylists", completion)
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                let result = try! decoder.decode(MKPlaylistResponse.self, from: data!)
                completion(result as AnyObject, nil)
            }
            else{
                self.sendErrorForHttpStatusCode(httpStatusCode, "taskForGetPlaylists", completion)
            }
        }
        
        task.resume()
    }
    
    func taskForPostPlaylist(playlistName: String, completion: @escaping (_ playlistResponse: AnyObject?, _ error: NSError?) -> Void) {
        
        var request = createURLRequest(MKConstants.Playlist)
        request.httpMethod = "POST"
        request.httpBody = """
            {
                "attributes":{
                    "name": "\(playlistName)"
                }
            }
            """.data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.sendError("Something went wrong, please try again", "taskForPostPlaylists", completion)
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.sendError("Something went wrong, please try again", "taskForPostPlaylists", completion)
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                let result = try! decoder.decode(MKPlaylistResponse.self, from: data!)
                completion(result as AnyObject, nil)
            }
            else{
                self.sendErrorForHttpStatusCode(httpStatusCode, "taskForPostPlaylists", completion)
            }
        }
        
        task.resume()
    }
}

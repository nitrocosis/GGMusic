//
//  MKSearchClient.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/20/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

class MKSearchClient: MKClient {
    
    static let shared = MKSearchClient()
    
    func taskForGetTracks(term: String, completion: @escaping (_ searchResponse: AnyObject?, _ error: NSError?) -> Void) {
        
        let storeFront = MusicKitConfig.shared.storeFrontCountryCode!
        let request = createURLRequest("\(MKConstants.Catalog)\(storeFront)\(MKConstants.Search)"
                                        + "?\(MKConstants.Types)=\(MKConstants.Songs)"
                                        + "&\(MKConstants.Limit)=\(MKConstants.SearchLimit)"
                                        + "&\(MKConstants.Term)=\(term)")
        
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
                let result = try! decoder.decode(MKTrackSearchResponse.self, from: data!)
                completion(result as AnyObject, nil)
            }
            else{
                self.sendErrorForHttpStatusCode(httpStatusCode, "taskForGetTracks", completion)
            }
        }
        
        task.resume()
    }
}

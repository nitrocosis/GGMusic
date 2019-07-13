//
//  Authentication.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/11/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import CoreData
import SwiftJWT

class Authentication {
    
    static let shared = Authentication()
    
    var dataController: DataController!
    
    private var developerToken: String!
    
    /*
     * Gets the developer token from core data. If not in core data, creates a new one.
     */
    func getDeveloperToken() -> String {
        // First, try to load developer token from core data.
        let authTokensRequest: NSFetchRequest<AuthTokens> = AuthTokens.fetchRequest()
        let authTokensArray: [AuthTokens] = try! dataController.viewContext.fetch(authTokensRequest)
        
        var authTokens: AuthTokens? = nil
        if (authTokensArray.count > 0) {
            authTokens = authTokensArray[0]
        }
        
        if (authTokens != nil && authTokens!.developerToken != nil) {
            developerToken = authTokens!.developerToken
        } else {
            // Token doesn't exist in core data, create a new one.
            developerToken = createDeveloperToken()
            
            authTokens = AuthTokens(context: dataController.viewContext)
            authTokens!.developerToken = developerToken
            saveTokens()
        }
        
        return developerToken
    }
    
    private func createDeveloperToken() -> String {
        let header = Header(kid: "B4AA2JUBGC")
        
        struct MyClaims: Claims {
            let iss: String
            let iat: Date
            let exp: Date
        }
        let claims = MyClaims(
            iss: "4VH6W5AH99",
            iat: Date(),
            exp: Calendar.current.date(byAdding: .month, value: 6, to: Date())!
        )
        
        var jwt = JWT(header: header, claims: claims)
        
        let keyFilePath = Bundle.main.path(forResource: "AuthKey_B4AA2JUBGC", ofType: "p8")!
        let keyFileUrl = URL(fileURLWithPath: keyFilePath)
        let privateKey = try! String(contentsOf: keyFileUrl).data(using: .utf8)!
        
        return try! jwt.sign(using: .es256(privateKey: privateKey))
    }
    
    private func saveTokens() {
        try? dataController.viewContext.save()
    }
}

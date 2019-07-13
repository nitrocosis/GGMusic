//
//  Authentication.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/11/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import SwiftJWT

class Authentication {
    
    func createDeveloperToken() -> String {
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
}

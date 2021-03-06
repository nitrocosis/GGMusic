//
//  MusicKitConfig.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/11/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import CoreData
import SwiftJWT
import StoreKit

class MusicKitConfig {
    
    static let shared = MusicKitConfig()
    
    var developerToken: String!
    var userToken: String!
    var storeFrontCountryCode: String! = "us"
    
    private var dataController: DataController!
    private var config: MKConfig!
    
    private let cloudServiceController = SKCloudServiceController()
    
    func setup(_ dataController: DataController) {
        self.dataController = dataController
        
        let configFromCoreData = getConfigFromCoreData()
        if (configFromCoreData != nil) {
            config = configFromCoreData!
        } else {
            config = MKConfig(context: dataController.viewContext)
        }
        
        developerToken = config.developerToken
        userToken = config.userToken
        storeFrontCountryCode = config.storeFrontCountryCode
        
        if (setupComplete()) {
            print("developerToken: \(developerToken) \nuserToken: \(userToken)")
        }
    }
    
    func setupComplete() -> Bool {
        return developerToken != nil && userToken != nil && storeFrontCountryCode != nil
    }
    
    func loadConfig(_ success: @escaping () -> Void, _ error: @escaping () -> Void) {
        self.loadDeveloperToken()
        self.loadStoreFrontCountryCode()
        self.loadUserToken(success, error)
    }
    
    /*
     * Loads the store front country code from core data. If not in core data, requests it.
     */
    private func loadStoreFrontCountryCode() {
        if (storeFrontCountryCode == nil) {
            print("Store front country code not in core data, requesting it")
            // Token doesn't exist in core data, request a new one.
            cloudServiceController.requestStorefrontCountryCode { (countryCode, countryCodeError) in
                if (countryCode == nil || countryCodeError != nil){
                    print("Store front country code request ERROR: \(countryCodeError?.localizedDescription)")
                }
                else {
                    print("Store front country code request SUCCESS: \(countryCode)")
                    self.storeFrontCountryCode = countryCode
                    self.config.storeFrontCountryCode = countryCode
                    self.saveConfig()
                }
            }
        } else {
            print("Store front in core data: \(config!.storeFrontCountryCode)")
            // Store front country code exists in core data.
            self.storeFrontCountryCode = config!.storeFrontCountryCode
        }
    }
    
    /*
     * Loads the user token from core data. If not in core data, requests a new one.
     */
    private func loadUserToken(_ success: @escaping () -> Void, _ error: @escaping () -> Void) {
        if (userToken == nil) {
            print("User token not in core data, requesting one")
            // Token doesn't exist in core data, request a new one.
            cloudServiceController.requestUserToken(forDeveloperToken: developerToken) { (userToken, userTokenError) in
                if (userToken == nil || userTokenError != nil){
                    print("User token request ERROR: \(userTokenError?.localizedDescription)")
                    error()
                }
                else {
                    print("User token request SUCCESS: \(userToken)")
                    self.userToken = userToken
                    self.config.userToken = userToken
                    self.saveConfig()
                    success()
                }
            }
        } else {
            print("User token in core data: \(config!.userToken)")
            // Token exists in core data.
            self.userToken = config!.userToken
            success()
        }
    }
    
    /*
     * Loads the developer token from core data. If not in core data, creates a new one.
     */
    private func loadDeveloperToken() {
        if (developerToken == nil) {
            print("Developer token not in core data, creating one")
            // Token doesn't exist in core data, create a new one.
            developerToken = createDeveloperToken()
            
            print("Developer token created: \(developerToken)")
            config.developerToken = developerToken
            saveConfig()
        } else {
            print("Developer token in core data: \(config!.developerToken)")
            // Token exists in core data.
            developerToken = config!.developerToken
        }
    }
    
    private func getConfigFromCoreData() -> MKConfig? {
        let configsRequest: NSFetchRequest<MKConfig> = MKConfig.fetchRequest()
        let configsArray: [MKConfig] = try! dataController.viewContext.fetch(configsRequest)
        
        var config: MKConfig? = nil
        if (configsArray.count > 0) {
            config = configsArray[0]
        }
        
        return config
    }
    
    private func createDeveloperToken() -> String {
        let header = Header(kid: "83G58KT5GU")
        
        struct MyClaims: Claims {
            let iss: String
            let iat: Date
            let exp: Date
        }
        let claims = MyClaims(
            iss: "4VH6W5AH99",
            iat: Date(),
            exp: Calendar.current.date(byAdding: .month, value: 3, to: Date())!
        )
        
        var jwt = JWT(header: header, claims: claims)
        
        let keyFilePath = Bundle.main.path(forResource: "AuthKey_83G58KT5GU", ofType: "p8")!
        let keyFileUrl = URL(fileURLWithPath: keyFilePath)
        let privateKey = try! String(contentsOf: keyFileUrl).data(using: .utf8)!
        
        return try! jwt.sign(using: .es256(privateKey: privateKey))
    }
    
    private func saveConfig() {
        try? dataController.viewContext.save()
    }
}

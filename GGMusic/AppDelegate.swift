//
//  AppDelegate.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let dataController = DataController(modelName: "GGMusic")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let loginVC = navigationController.topViewController as! LoginVC
        loginVC.dataController = dataController
        
        Authentication.shared.dataController = dataController
        return true
    }
    

}



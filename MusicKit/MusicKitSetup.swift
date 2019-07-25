//
//  MusicKitSetup.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/14/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import StoreKit

class MusicKitSetup: NSObject, SKCloudServiceSetupViewControllerDelegate {
    
    static let shared = MusicKitSetup()
    
    private let cloudServiceController = SKCloudServiceController()
    
    private var signupScreenDismissed: (() -> Void)!
    
    func setupAccount(callerVC: UIViewController,
                      success: @escaping () -> Void,
                      error: @escaping () -> Void,
                      signupScreenDismissed: @escaping () -> Void) {
        
        SKCloudServiceController.requestAuthorization { (status) in
            switch (status) {
            case .notDetermined:
                print("STATUS - not determined")
                error()
            case .denied:
                print("STATUS - denied")
                error()
            case .restricted:
                print("STATUS - restricted")
                error()
            case .authorized:
                print("STATUS - authorized")
                self.cloudServiceController.requestCapabilities { capabilities, capabilitiesError in
                    if capabilities.contains(.musicCatalogPlayback) {
                        print("User has Apple Music account. Load the config.")
                        // User has Apple Music account. Load the config.
                        MusicKitConfig.shared.loadConfig(success, error)
                    }
                    else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                        print("User can sign up to Apple Music.")
                        // User can sign up to Apple Music.
                        self.signupScreenDismissed = signupScreenDismissed
                        self.showAppleMusicSignup(callerVC)
                    } else {
                        print("User cannot use this app: \(capabilitiesError?.localizedDescription).")
                        error()
                    }
                }
            }
        }
    }
    
    private func showAppleMusicSignup(_ callerVC: UIViewController) {
        let signupVC = SKCloudServiceSetupViewController()
        signupVC.delegate = self
        
        let options: [SKCloudServiceSetupOptionsKey: Any] = [
            .action: SKCloudServiceSetupAction.subscribe,
            .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic
        ]
        
        signupVC.load(options: options) { success, error in
            if success {
                callerVC.present(signupVC, animated: true)
            }
        }
    }
    
    func cloudServiceSetupViewControllerDidDismiss(_ cloudServiceSetupViewController: SKCloudServiceSetupViewController) {
        signupScreenDismissed()
    }
}

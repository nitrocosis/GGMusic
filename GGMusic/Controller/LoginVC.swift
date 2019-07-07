//
//  LoginVC.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        let client = SpotifyClient.sharedInstance()
        if (client.isSpotifyAppInstalled()) {
            if (client.isLoggedIn()) {
                startPlaylistCollectionVC()
            } else {
                // TODO Show "Login with Spotify" button.
            }
        } else {
            // TODO Show "Install Spotify" button.
            // When clicked should show the Spotify app in the App Store.
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        loginWithSpotify()
    }
    
    @IBAction func signUp(_ sender: Any) {
    }
    
    private func loginWithSpotify() {
        SpotifyClient.sharedInstance().login(
            success: {
                self.startPlaylistCollectionVC()
            },
            failed: {
                self.displayError("Login failed. Please try again.")
            }
        )
    }
    
    private func startPlaylistCollectionVC() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PlaylistCollectionVC")
        self.present(controller, animated: true, completion: nil)
    }
}

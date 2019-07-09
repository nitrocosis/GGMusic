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
    
    @IBOutlet weak var loginWithSpotifyButton: UIButton!
    @IBOutlet weak var installSpotifyButton: UIButton!
    @IBOutlet weak var installSpotifyLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
       // loginWithSpotifyButton.isHidden = true
        installSpotifyButton.isHidden = true
        let client = SpotifyClient.sharedInstance()
        if (client.isSpotifyAppInstalled()) {
            if (client.isLoggedIn()) {
                startPlaylistCollectionVC()
            } else {
                // TODO Show "Login with Spotify" button.
                loginWithSpotifyButton.isHidden = false
            }
        } else {
            installSpotifyButton.isHidden = false
            // TODO Show "Install Spotify" button.
            // When clicked should show the Spotify app in the App Store.
            
        }
    }
    
    @IBAction func loginWithSpotify(_ sender: Any) {
        activityIndicator.startAnimating()
        loginWithSpotify()
    }
    
    @IBAction func installSpotifyButton(_ sender: Any) {
        if let url = URL(string: "itms-apps://apps.apple.com/us/app/spotify-music-and-podcasts/id324684580"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.openURL(url)
        }
    }
    
    private func loginWithSpotify() {
        SpotifyClient.sharedInstance().login(
            success: {
                self.startPlaylistCollectionVC()
            },
            failed: {
                self.activityIndicator.stopAnimating()
                self.displayError("Login failed. Please try again.")
            }
        )
    }
    
    private func startPlaylistCollectionVC() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PlaylistCollectionVC")
        self.present(controller, animated: true, completion: nil)
    }
}

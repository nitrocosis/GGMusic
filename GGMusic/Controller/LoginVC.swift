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
    
    var dataController: DataController!
    
    @IBOutlet weak var loginWithSpotifyButton: UIButton!
    @IBOutlet weak var installSpotifyButton: UIButton!
    @IBOutlet weak var installSpotifyLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
       loginWithSpotifyButton.isHidden = false
        
        // TODO Write method to check if config is in core data.
        // If so, just start playlist VC. Otherwise, show "Get Started" button.
        
        // TODO Show "Get Started" button
        // TODO clean up this VC. Remove all spotify shit.
        // TODO Fix up UI.
        getStartedButtonClicked()
    }
    
    private func getStartedButtonClicked() {
        setupMusicKit()
    }
    
    private func setupMusicKit() {
        MusicKitSetup.shared.setupAccount(callerVC: self, success: {
            print("MusicKit setup success")
            // TODO Start playlist VC
        }, error: {
            print("MusicKit setup error")
        }, signupScreenDismissed: {
            print("MusicKit sign up screen dismissed")
            self.setupMusicKit()
        })
    }
    
    @IBAction func loginWithSpotify(_ sender: Any) {
        activityIndicator.startAnimating()
    }
    
    @IBAction func installSpotifyButton(_ sender: Any) {
        if let url = URL(string: "itms-apps://apps.apple.com/us/app/spotify-music-and-podcasts/id324684580"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.openURL(url)
        }
    }
    
    private func startPlaylistCollectionVC() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "PlaylistCollectionVC")
        self.present(controller, animated: true, completion: nil)
    }
}

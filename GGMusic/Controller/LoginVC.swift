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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        if (MusicKitConfig.shared.setupComplete()) {
            startPlaylistCollectionVC()
        }
    }
    
    @IBAction func getStartedButton(_ sender: Any) {
        activityIndicator.startAnimating()
        setupMusicKit()
    }
    
    private func setupMusicKit() {
        MusicKitSetup.shared.setupAccount(callerVC: self, success: {
            print("MusicKit setup success")
            self.startPlaylistCollectionVC()
        }, error: {
            print("MusicKit setup error")
            self.displayError("Something went wrong. Please try again.")
        }, signupScreenDismissed: {
            print("MusicKit sign up screen dismissed")
            self.setupMusicKit()
        })
    }
    
    private func startPlaylistCollectionVC() {
        DispatchQueue.main.async {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "PlaylistCollectionVC")
            let playlistCollectionVC = controller as! PlaylistCollectionVC
            playlistCollectionVC.dataController = self.dataController
            self.present(controller, animated: true, completion: nil)
        }
    }
}

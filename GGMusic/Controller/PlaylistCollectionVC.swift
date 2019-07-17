//
//  CollectionVC.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import UIKit

//downloads playlists from Spotify + allows creation of own playlists (pop up with title)

class PlaylistCollectionVC: UIViewController {
    
    private let PlaylistCellReuseIdentifier = "Cell"
    var dataController: DataController!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MKPlaylistClient.shared.getPlaylists() { (playlistResponse, error) in
            print("Response: \(playlistResponse)")
            print("Error: \(error)")
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createPlaylistButton(_ sender: Any) {
        presentNewPlaylistAlert()
    }
    
    func presentNewPlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter a name for this playlist", preferredStyle: .alert)
        
        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.createPlaylist(name: name)
            }
        }
        saveAction.isEnabled = false
        
        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }
    
    func createPlaylist(name: String) {
        //create empty playlist with Placeholder img and name as label and save to core data
    }
    
    func holdToDelete() {
        //hold to delete playlist with alert
    }
    
}

extension PlaylistCollectionVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCellReuseIdentifier, for: indexPath)
        return cell
    }
    
}

extension PlaylistCollectionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}



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
    
    var playlists: [Playlist]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Immediately show playlists in core data, if any.
        showPlaylists()
        
        // Then get playlists from network to get updated playlists.
        getPlaylists()
    }
    
    private func showPlaylists() {
        // TODO Hide the loading state and show the Playlists (populated state) in the collection view.
        // TODO If there are no Playlists, show the empty state.
    }
    
    private func getPlaylists() {
        // TODO Show loading state if there are currently no Playlists shown in the collection view.
        MKPlaylistClient.shared.getPlaylists() { (playlistResponse, error) in
            if (error != nil) {
                print("ERROR - getPlaylists: \(error)")
                // TODO If there is an error and there are no Playlists in core data, show the error state.
                // TODO If there is an error but there are Playlists in core data, do nothing.
            } else {
                print("SUCCESS - getPlaylists: \(playlistResponse)")
                // Delete all of the Playlists from core data.
                // TODO
                // Create the Playlist core data objects from the playlistResponse.
                // TODO
                // Save the Playlists.
                self.savePlaylists()
                // Populate the collection view with the Playlists.
                self.showPlaylists()
            }
        }
    }
    
    private func savePlaylists() {
        try? dataController.viewContext.save()
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
        MKPlaylistClient.shared.postPlaylist(name: name) { (playlistResponse, error) in
            if (error != nil) {
                // TODO
            } else {
                // TODO
            }
        }
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



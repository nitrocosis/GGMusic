//
//  CollectionVC.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import CoreData
import UIKit

//downloads playlists from Spotify + allows creation of own playlists (pop up with title)

class PlaylistCollectionVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var dataController: DataController!
    var playlists: [Playlist] = Array()
    
    var state = PlaylistState.loading {
        didSet {
            playlists = Array()
            
            switch state {
            case .loading:
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.center = collectionView.center
                collectionView.backgroundView  = activityIndicator
                activityIndicator.startAnimating()
                
            case .populated(let resultPlaylists):
                collectionView.backgroundView = nil
                playlists = resultPlaylists
                self.savePlaylists()

            case .empty:
                let frame = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
                let noDataLabel = UILabel(frame: frame)
                noDataLabel.text = NSLocalizedString("No playlists", comment: "")
                noDataLabel.textAlignment = .center
                collectionView.backgroundView  = noDataLabel
                
            case .error(let error):
                let frame = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
                let errorLabel = UILabel(frame: frame)
                errorLabel.text = error.localizedDescription
                errorLabel.textAlignment = .center
                collectionView.backgroundView  = errorLabel
            }
            
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        // Immediately show playlists in core data, if any.
        showPlaylists()
        
        // Then get playlists from network to get updated playlists.
        getPlaylists()
    }
    
    private func showPlaylists() {
        // Hide the loading state and show the Playlists (populated state) in the collection view.
        let playlistsFromCoreData = getPlaylistsFromCoreData()
        if (playlistsFromCoreData.count > 0) {
            state = .populated(playlistsFromCoreData)
        } else {
            // If there are no Playlists, show the empty state.
            state = .empty
        }
    }
    
    private func getPlaylistsFromCoreData() -> [Playlist] {
        let playlistsRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        playlistsRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try! dataController.viewContext.fetch(playlistsRequest)
    }
    
    private func getPlaylists() {
        // Show loading state if there are currently no Playlists shown in the collection view.
        let noPlaylists = playlists.count == 0
        if (noPlaylists) {
            state = .loading
        }
        
        MKPlaylistClient.shared.getPlaylists() { (playlistResponse, error) in
            DispatchQueue.main.async {
                if (error != nil) {
                    // If there is an error and there are no Playlists in core data, show the error state.
                    if (noPlaylists) {
                        self.state = .error(error!)
                    }
                    // If there is an error but there are Playlists in core data, do nothing.
                } else {
                    // Delete all of the Playlists from core data that are not in the playlistResponse
                    // if they are expired (past 20 seconds).
                    self.deleteExpiredPlaylists(playlistResponse!.data)
                    // Create the Playlist core data objects from the playlistResponse.
                    self.savePlaylists(playlistResponse!.data)
                    // Populate the collection view with the Playlists.
                    self.showPlaylists()
                }
            }
        }
    }
    
    private func savePlaylists(_ mkPlaylists: [MKPlaylist]) {
        for mkPlaylist in mkPlaylists {
            let mkPlaylistNotInPlaylists = !playlists.contains { (playlist) -> Bool in
                mkPlaylist.id == playlist.id!
            }
            
            if (mkPlaylistNotInPlaylists) {
                createPlaylist(from: mkPlaylist)
            }
        }
        savePlaylists()
    }
    
    private func createPlaylist(from mkPlaylist: MKPlaylist) -> Playlist {
        let playlist = Playlist(context: dataController.viewContext)
        playlist.id = mkPlaylist.id
        playlist.name = mkPlaylist.attributes.name
        playlist.url = mkPlaylist.attributes.artwork.getUrl()
        playlist.created = Date()
        return playlist
    }
    
    private func savePlaylists() {
        try? dataController.viewContext.save()
    }
    
    private func deleteExpiredPlaylists(_ mkPlaylists: [MKPlaylist]) {
        for (index, playlist) in playlists.enumerated() {
            let playlistNotInMKPlaylist = !mkPlaylists.contains { (mkPlaylist) -> Bool in
                playlist.id! == mkPlaylist.id
            }
            
            let currentDate = Date()
            let date20SecAfterCreated = playlist.created!.addingTimeInterval(20)
            let playlistIsExpired = currentDate > date20SecAfterCreated
            
            if (playlistNotInMKPlaylist && playlistIsExpired) {
                dataController.viewContext.delete(playlist)
                playlists.remove(at: index)
            }
        }
        savePlaylists()
    }
    
    private func storeImageData(_ imageData: Data, _ playlist: Playlist) {
        playlist.image = imageData
        savePlaylists()
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
        showActivityIndicator()
        MKPlaylistClient.shared.postPlaylist(name: name) { (playlistResponse, error) in
            DispatchQueue.main.async {
                self.dismissActivityIndicator()
                if (error != nil) {
                    self.displayError(error?.description)
                } else {
                    // Create empty playlist with Placeholder img and name as label and save to core data.
                    // Then, reload the collection view.
                    let playlist = self.createPlaylist(from: playlistResponse!.data[0])
                    self.savePlaylists()
                    self.playlists.append(playlist)
                    self.playlists.sort(by: { $0.name! <= $1.name! })
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self as UICollectionViewDataSource
        collectionView.delegate = self as UICollectionViewDelegate
        collectionView.allowsMultipleSelection = false
        setupCollectionViewLayout()
    }
    
    private func setupCollectionViewLayout() {
        let itemsPerRow: CGFloat = 3
        let itemsPadding: CGFloat = 5.0
        
        let paddingSpace = itemsPadding * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        flowLayout.itemSize = CGSize(width: widthPerItem, height: widthPerItem)
        flowLayout.minimumLineSpacing = itemsPadding
        flowLayout.minimumInteritemSpacing = itemsPadding
        
        collectionView.contentInset = UIEdgeInsets(top: itemsPadding,
                                                   left: itemsPadding,
                                                   bottom: itemsPadding,
                                                   right: itemsPadding)
    }
}

extension PlaylistCollectionVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
}

extension PlaylistCollectionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        let collectionViewCell = cell as! CollectionViewCell
        let playlist = playlists[indexPath.row] as Playlist
        
        collectionViewCell.label.text = playlist.name
        
        guard let imageURL = URL(string: playlist.url!) else { return }
        
        if let imageData = playlist.image {
            DispatchQueue.main.async {
                collectionViewCell.imageView.image = UIImage(data: imageData)
            }
        } else {
            URLSession.shared.dataTask(with: imageURL) { (data, _, _) in
                if let imageData = data {
                    self.storeImageData(imageData, playlist)
                    DispatchQueue.main.async {
                        collectionViewCell.imageView.image = UIImage(data: imageData)
                    }
                }
            }.resume()
        }
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)!
        let index = (indexPath.section * 3) + indexPath.row
        let playlist = playlists[index] as Playlist
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "SongListVC")
        let songListVC = controller as! SongListVC
        songListVC.dataController = self.dataController
        songListVC.playlist = playlist
        self.present(controller, animated: true, completion: nil)
    }
}

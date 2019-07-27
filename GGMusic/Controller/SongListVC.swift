//
//  TableVC.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import UIKit
//Shuffle and play buttons. list of songs in playlist. search bar allows you to search for spotify songs and add to current playlist.

class SongListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var playlistTitleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var dataController: DataController!
    var playlist: Playlist!
    
    var state = SongListState.loading {
        didSet {
            switch state {
            case .loading:
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.center = tableView.center
                tableView.backgroundView  = activityIndicator
                activityIndicator.startAnimating()
                
            case .populated(let resultPlaylist):
                tableView.backgroundView = nil
                playlist = resultPlaylist
                self.savePlaylist()
                
            case .empty:
                let frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
                let noDataLabel = UILabel(frame: frame)
                noDataLabel.text = NSLocalizedString("No playlists", comment: "")
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                
            case .error(let error):
                let frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
                let errorLabel = UILabel(frame: frame)
                errorLabel.text = error.localizedDescription
                errorLabel.textAlignment = .center
                tableView.backgroundView  = errorLabel
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Immediately show songs of the playlist in core data, if any.
        showSongs()
        
        // Then get songs of the playlists from network to get updated playlists.
        getSongs()
    }
    
    private func showSongs() {
        // Hide the loading state and show the Playlist sonhs (populated state) in the collection view.
        if (playlist.song!.count > 0) {
            state = .populated(playlist)
        } else {
            // If there are no Playlists, show the empty state.
            state = .empty
        }
    }
    
    private func getSongs() {
        // Show loading state if there are currently no songs shown in the table view.
        let noSongs = playlist.song!.count == 0
        if (noSongs) {
            state = .loading
        }
        
        MKTrackClient.shared.getTracks(playlistId: playlist.id!) { (trackResponse, error) in
            DispatchQueue.main.async {
                if (error != nil) {
                    // If there is an error and there are no songs in core data, show the error state.
                    if (noSongs) {
                        self.state = .error(error!)
                    }
                    // If there is an error but there are songs in core data, do nothing.
                } else {
                    // Delete all of the songs from core data that are not in the trackResponse
                    // if they are expired (past 20 seconds).
                    self.deleteExpiredSongs(trackResponse!.data)
                    // Create the song core data objects from the trackResponse.
                    self.saveSongs(trackResponse!.data)
                    // Populate the table view with the songs.
                    self.showSongs()
                }
            }
        }
    }
    
    private func saveSongs(_ mkTracks: [MKTrack]) {
        for mkTrack in mkTracks {
            let mkTrackNotInSongs = !playlist.song!.contains { (song) -> Bool in
                let song = song as! Song
                return mkTrack.id == song.id!
            }
            
            if (mkTrackNotInSongs) {
                let song = createSong(from: mkTrack)
                playlist.addToSong(song)
            }
        }
        savePlaylist()
    }
    
    private func createSong(from mkTrack: MKTrack) -> Song {
        let song = Song(context: dataController.viewContext)
        song.id = mkTrack.id
        song.albumName = mkTrack.attributes?.albumName
        song.artistName = mkTrack.attributes?.artistName
        song.created = Date()
        song.name = mkTrack.attributes?.name
        song.type = mkTrack.type
        song.url = mkTrack.attributes?.artwork?.getUrl()
        return song
    }
    
    private func savePlaylist() {
        try? dataController.viewContext.save()
    }
    
    private func deleteExpiredSongs(_ mkTracks: [MKTrack]) {
        for (index, song) in playlist.song!.enumerated() {
            let song = song as! Song
            let songNotInMKTracks = !mkTracks.contains { (mkTrack) -> Bool in
                song.id! == mkTrack.id
            }
            
            let currentDate = Date()
            let date20SecAfterCreated = song.created!.addingTimeInterval(20)
            let songIsExpired = currentDate > date20SecAfterCreated
            
            if (songNotInMKTracks && songIsExpired) {
                playlist.removeFromSong(song)
                dataController.viewContext.delete(song)
            }
        }
        savePlaylist()
    }
    
    private func storeImageData(_ imageData: Data, _ song: Song) {
        song.image = imageData
        savePlaylist()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.dataSource = self as UITableViewDataSource
        tableView.delegate = self as UITableViewDelegate
        tableView.allowsMultipleSelection = false
    }
}

extension SongListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.song!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
}

extension SongListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        let tableViewCell = cell as! TableViewCell
        let songs = playlist.song!.allObjects as! [Song]
        let song = songs[indexPath.row] as Song
        
        tableViewCell.songName.text = song.name
        tableViewCell.artistName.text = song.artistName
        
        guard let imageURL = URL(string: song.url!) else { return }
        
        if let imageData = song.image {
            DispatchQueue.main.async {
                tableViewCell.songImage.image = UIImage(data: imageData)
            }
        } else {
            URLSession.shared.dataTask(with: imageURL) { (data, _, _) in
                if let imageData = data {
                    self.storeImageData(imageData, song)
                    DispatchQueue.main.async {
                        tableViewCell.songImage.image = UIImage(data: imageData)
                    }
                }
                }.resume()
        }
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        // TODO
    }
}

//
//  TableVC.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import UIKit

class SongListVC: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistTitleLabel: UILabel!
    @IBOutlet weak var nowPlayingMainView: UIView!
    @IBOutlet weak var nowPlayingImageView: UIImageView!
    @IBOutlet weak var nowPlayingTitleLabel: UILabel!
    @IBOutlet weak var nowPlayingPlayButton: UIButton!
    @IBOutlet weak var nowPlayingNextButton: UIButton!
    
    private var nowPlayingMainViewTapGestureRecognizer: UIGestureRecognizer!
    
    var dataController: DataController!
    var playlist: Playlist!
    var searchResults: [MKTrack]?
    
    let player = MKPlayer()
    
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
                noDataLabel.text = NSLocalizedString("No songs", comment: "")
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
        setPlayerViews()
        
        playlistTitleLabel.text = playlist.name
        searchBar.delegate = self
        
        setupTableView()
        
        // Immediately show songs of the playlist in core data, if any.
        showSongs()
        
        // Then get songs of the playlists from network to get updated playlists.
        getSongs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.setupPlayer()
        
        nowPlayingMainViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nowPlayingMainViewTapped(_:)))
        nowPlayingMainView.addGestureRecognizer(nowPlayingMainViewTapGestureRecognizer)
        nowPlayingMainView.isHidden = !player.hasNowPlayingItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.releasePlayer()
        nowPlayingMainView.removeGestureRecognizer(nowPlayingMainViewTapGestureRecognizer)
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
                let catalogId = mkTrack.attributes?.playParams?.catalogId
                
                return catalogId == nil || catalogId == song.id!
            }
            
            if (mkTrackNotInSongs) {
                let song = createSong(from: mkTrack, useCatalogId: true)
                if (song != nil) {
                    playlist.addToSong(song!)
                }
            }
        }
        savePlaylist()
    }
    
    private func createSong(from mkTrack: MKTrack, useCatalogId: Bool) -> Song? {
        let song = Song(context: dataController.viewContext)
        
        if (useCatalogId) {
            song.id = mkTrack.attributes?.playParams?.catalogId
            if (song.id == nil) {
                return nil
            }
        } else {
            song.id = mkTrack.id
        }
        
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
        for song in playlist.song! {
            let song = song as! Song
            let songNotInMKTracks = !mkTracks.contains { (mkTrack) -> Bool in
                let catalogId = mkTrack.attributes?.playParams?.catalogId
                
                return catalogId == nil || catalogId == song.id!
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
    
    private func showSearchResults() {
        if (searchResults == nil || searchResults!.isEmpty) {
            displayError("No songs found!")
            return
        }
        
        // show search results in the table view
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let term = searchBar.text
        if (term == nil || term!.isEmpty) {
            return
        }
        
        showActivityIndicator()
        MKSearchClient.shared.searchTracks(term: term!) { (trackResponse, error) in
            DispatchQueue.main.async {
                self.dismissActivityIndicator()
                if (error != nil) {
                    self.searchResults = nil
                    self.displayError(error!.description)
                } else {
                    if (trackResponse != nil && trackResponse!.data.isEmpty) {
                        self.displayError("No results!")
                    } else {
                        self.searchResults = trackResponse?.data
                        self.showSearchResults()
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if (searchResults != nil) {
            searchResults = nil
            searchBar.text = nil
            tableView.reloadData()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func playButton(_ sender: Any) {
        let songs = playlist.song!.allObjects as! [Song]
        let songIds = songs.map { (song: Song) -> String in song.id! }
        showMusicPlayerVC(songIds, nil)
    }
    
    @IBAction func shuffleButton(_ sender: Any) {
        let songs = playlist.song!.allObjects as! [Song]
        let songIds = songs.map { (song: Song) -> String in song.id! }
        let shuffledSongIds = songIds.shuffled()
        showMusicPlayerVC(shuffledSongIds, nil)
    }
    
    @objc func nowPlayingMainViewTapped(_ sender: UITapGestureRecognizer) {
        showMusicPlayerVC(nil, nil)
    }
    
    private func showMusicPlayerVC(_ songIds: [String]?, _ firstSongId: String?) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "MusicPlayerVC")
        let musicPlayerVC = controller as! MusicPlayerVC
        
        musicPlayerVC.songIds = songIds
        musicPlayerVC.firstSongId = firstSongId
        musicPlayerVC.modalPresentationStyle = .pageSheet
        
        self.present(controller, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.dataSource = self as UITableViewDataSource
        tableView.delegate = self as UITableViewDelegate
        tableView.allowsMultipleSelection = false
    }
    
    private func setPlayerViews() {
        player.imageView = nowPlayingImageView
        player.songTitleLabel = nowPlayingTitleLabel
        player.playSongButton = nowPlayingPlayButton
        player.nextSongButton = nowPlayingNextButton
    }
}

extension SongListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchResults != nil) {
            return searchResults!.count
        }
        return playlist.song!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
}

extension SongListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let tableViewCell = cell as! TableViewCell
        
        tableViewCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCell(_:))))
        tableViewCell.addButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAddButton(_:))))
        
        if (searchResults != nil) {
            let mkTrack = searchResults![indexPath.row]
            loadTableViewCell(with: mkTrack, tableViewCell)
        } else {
            let songs = playlist.song!.allObjects as! [Song]
            let song = songs[indexPath.row] as Song
            loadTableViewCell(with: song, tableViewCell)
        }
    }
    
    private func loadTableViewCell(with song: Song, _ tableViewCell: TableViewCell) {
        tableViewCell.addButton.isHidden = true
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
    
    private func loadTableViewCell(with mkTrack: MKTrack, _ tableViewCell: TableViewCell) {
        tableViewCell.addButton.isHidden = false
        tableViewCell.songName.text = mkTrack.attributes?.name
        tableViewCell.artistName.text = mkTrack.attributes?.artistName
        
        guard let imageURL = URL(string: (mkTrack.attributes?.artwork?.getUrl())!) else { return }
        
        URLSession.shared.dataTask(with: imageURL) { (data, _, _) in
            if let imageData = data {
                DispatchQueue.main.async {
                    tableViewCell.songImage.image = UIImage(data: imageData)
                }
            }
            }.resume()
    }
    
    @objc func tapCell(_ sender: UITapGestureRecognizer) {
        if (searchResults != nil) {
            let mkTrack = getMKTrack(from: sender)
            showMusicPlayerVC([mkTrack.id], nil)
        } else {
            let songs = playlist.song!.allObjects as! [Song]
            let songIds = songs.map { (song: Song) -> String in song.id! }
            let index = getIndex(from: sender)
            let firstSongId = songs[index].id!
            player.play(songIds: songIds, firstSongId: firstSongId)
        }
    }
    
    @objc func tapAddButton(_ sender: UITapGestureRecognizer) {
        let mkTrack = getMKTrack(from: sender)
        
        showActivityIndicator()
        MKTrackClient.shared.addTracks(playlistId: playlist.id!, tracks: [mkTrack]) { (trackResponse, error) in
            DispatchQueue.main.async {
                self.dismissActivityIndicator()
                if (error != nil) {
                    self.displayError(error!.description)
                } else {
                    let song = self.createSong(from: mkTrack, useCatalogId: false)
                    if (song != nil) {
                        self.playlist.addToSong(song!)
                        self.savePlaylist()
                        self.displaySuccess()
                    }
                }
            }
        }
    }
    
    private func getIndex(from sender: UITapGestureRecognizer) -> Int {
        let location = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)!
        let index = indexPath.section + indexPath.row
        return index
    }
    
    private func getMKTrack(from sender: UITapGestureRecognizer) -> MKTrack {
        let index = getIndex(from: sender)
        let mkTrack = searchResults![index] as MKTrack
        return mkTrack
    }
}

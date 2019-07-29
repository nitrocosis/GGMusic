//
//  ViewController.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayerVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var playSongButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var changeBackgroundButton: UIButton!
    
    // TODO only need to pass in array of ids!!!
    var songIds: [String]?
    var firstSongId: String?
    
    private var player: MPMusicPlayerController!
    
    private var playbackStateChangedObserver: NSObjectProtocol?
    private var nowPlayingItemChangedObserver: NSObjectProtocol?
    private var volumeChangedObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPlayer()
        playSongs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        releasePlayer()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func playSongs() {
        let queue  = MPMusicPlayerStoreQueueDescriptor(storeIDs: songIds!)
        queue.startItemID = firstSongId
        
        player.setQueue(with: queue)
        player.play()
    }
    
    private func playbackStateChanged() {
        // TODO
        print("PLAYBACK STATE CHANGED: \(player.playbackState)")
    }
    
    private func nowPlayingItemChanged() {
        // TODO
        print("NOW PLAYING ITEM CHANGED: \(player.nowPlayingItem?.artwork)")
    }
    
    private func volumeChanged() {
        // TODO
        print("VOLUME CHANGED: \(AVAudioSession.sharedInstance().outputVolume)")
    }
    
    private func setupPlayer() {
        player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()
        
        playbackStateChangedObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange,
            object: player,
            queue: nil) { (notification) in
                self.playbackStateChanged()
        }
        
        nowPlayingItemChangedObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player,
            queue: nil) { (notification) in
                self.nowPlayingItemChanged()
        }
        
        volumeChangedObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange,
            object: player,
            queue: nil) { (notification) in
                self.volumeChanged()
        }
    }
    
    private func releasePlayer() {
        player.endGeneratingPlaybackNotifications()
        
        NotificationCenter.default.removeObserver(
            playbackStateChangedObserver as Any,
            name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            nowPlayingItemChangedObserver as Any,
            name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            volumeChangedObserver as Any,
            name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange,
            object: nil
        )
    }
}


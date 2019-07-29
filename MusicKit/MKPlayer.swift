//
//  MKPlayer.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/28/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import MediaPlayer
import UIKit

class MKPlayer {
    
    var imageView: UIImageView?
    var songArtistLabel: UILabel?
    var songTitleLabel: UILabel?
    var previousSongButton: UIButton?
    var playSongButton: UIButton?
    var nextSongButton: UIButton?
    var volumeSlider: UISlider?
    
    private var player: MPMusicPlayerController!
    private var playbackStateChangedObserver: NSObjectProtocol?
    private var nowPlayingItemChangedObserver: NSObjectProtocol?
    private var volumeChangedObserver: NSObjectProtocol?
    
    func setupPlayer() {
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
    
    func releasePlayer() {
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
    
    func play(songIds: [String], firstSongId: String?) {
        let queue  = MPMusicPlayerStoreQueueDescriptor(storeIDs: songIds)
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
}

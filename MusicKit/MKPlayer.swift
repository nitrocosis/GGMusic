//
//  MKPlayer.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/28/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import CoreGraphics
import MediaPlayer
import UIKit

class MKPlayer {
    
    var imageView: UIImageView?
    var songArtistLabel: UILabel?
    var songTitleLabel: UILabel?
    var previousSongButton: UIButton?
    var playSongButton: UIButton?
    var nextSongButton: UIButton?
    
    private var previousTapGestureRecognizer: UIGestureRecognizer!
    private var playTapGestureRecognizer: UIGestureRecognizer!
    private var nextTapGestureRecognizer: UIGestureRecognizer!
    
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
        
        previousTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(previousButtonTapped(_:)))
        playTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped(_:)))
        nextTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextButtonTapped(_:)))
        
        previousSongButton?.addGestureRecognizer(previousTapGestureRecognizer)
        playSongButton?.addGestureRecognizer(playTapGestureRecognizer)
        nextSongButton?.addGestureRecognizer(nextTapGestureRecognizer)
        
        populateViewsWithNowPlayingItem()
        updatePlayButtonState()
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
        
        previousSongButton?.removeGestureRecognizer(previousTapGestureRecognizer)
        playSongButton?.removeGestureRecognizer(playTapGestureRecognizer)
        nextSongButton?.removeGestureRecognizer(nextTapGestureRecognizer)
    }
    
    func hasNowPlayingItem() -> Bool {
        return player.nowPlayingItem != nil
    }
    
    func play(songIds: [String], firstSongId: String?) {
        let queue  = MPMusicPlayerStoreQueueDescriptor(storeIDs: songIds)
        queue.startItemID = firstSongId
        
        player.setQueue(with: queue)
        player.play()
    }
    
    @objc func previousButtonTapped(_ sender: UITapGestureRecognizer) {
        player.skipToPreviousItem()
    }
    
    @objc func playButtonTapped(_ sender: UITapGestureRecognizer) {
        switch player.playbackState {
        case .playing:
            player.pause()
        default:
            player.play()
        }
    }
    
    @objc func nextButtonTapped(_ sender: UITapGestureRecognizer) {
        player.skipToNextItem()
    }
    
    private func playbackStateChanged() {
        updatePlayButtonState()
    }
    
    private func nowPlayingItemChanged() {
        populateViewsWithNowPlayingItem()
    }
    
    private func updatePlayButtonState() {
        switch player.playbackState {
        case .playing:
            playSongButton?.setTitle("Pause", for: .normal)
        default:
            playSongButton?.setTitle("Play", for: .normal)
        }
    }
    
    private func populateViewsWithNowPlayingItem() {
        guard let nowPlayingItem = player.nowPlayingItem else { return }
        
        if (imageView != nil) {
            let imageViewSize = CGSize(width: imageView!.frame.width, height: imageView!.frame.height)
            imageView!.image = nowPlayingItem.artwork?.image(at: imageViewSize)
        }
        
        songArtistLabel?.text = nowPlayingItem.artist
        songTitleLabel?.text = nowPlayingItem.title
    }
}

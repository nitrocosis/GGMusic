//
//  ViewController.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 6/19/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import UIKit

class MusicPlayerVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var playSongButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    var songIds: [String]?
    var firstSongId: String?
    
    let player = MKPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.imageView = imageView
        player.songArtistLabel = songArtistLabel
        player.songTitleLabel = songTitleLabel
        player.previousSongButton = previousSongButton
        player.playSongButton = playSongButton
        player.nextSongButton = nextSongButton
        player.volumeSlider = volumeSlider
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.setupPlayer()
        player.play(songIds: songIds!, firstSongId: firstSongId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.releasePlayer()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

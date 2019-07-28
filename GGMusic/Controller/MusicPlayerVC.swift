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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


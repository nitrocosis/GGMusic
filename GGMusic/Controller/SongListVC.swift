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
    
    @IBOutlet weak var playlistTitleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var dataController: DataController!
    var playlist: Playlist!

}



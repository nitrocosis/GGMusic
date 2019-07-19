//
//  PlaylistState.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/18/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation

enum PlaylistState {
    case loading
    case populated([Playlist])
    case empty
    case error(NSError)
}

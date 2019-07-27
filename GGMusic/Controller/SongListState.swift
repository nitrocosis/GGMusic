//
//  SongListState.swift
//  GGMusic
//
//  Created by Sarah Rebecca Estrellado on 7/25/19.
//  Copyright © 2019 Sarah Rebecca Estrellado. All rights reserved.
//

import Foundation
import CoreData

enum SongListState {
    case loading
    case populated(Playlist)
    case empty
    case error(NSError)
}

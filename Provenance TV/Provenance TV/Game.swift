//
//  Game.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-12.
//  Copyright © 2015 Provenance. All rights reserved.
//

import Foundation

struct Game {
    
    var title: String
    var romPath: String
    var originalArtworkURL: String
    var md5Hash: String
    var systemIdentifier: String
    
    init (romPath: String, systemIdentifier: String) {
        
        self.romPath = romPath
        self.systemIdentifier = systemIdentifier
        
        self.title = ""
        self.originalArtworkURL = ""
        self.md5Hash = ""
        
    }
}

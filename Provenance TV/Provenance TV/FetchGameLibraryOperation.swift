//
//  FetchGameLibraryOperation.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-16.
//  Copyright © 2015 Provenance. All rights reserved.
//

import Foundation

class FetchGameLibraryOperation: NSOperation {
    
    let path: String
    let systemId: String
    let completion: (([Game]) -> Void)
    
    init(path: String, systemId: String, completion: (([Game]) -> Void)) {

        self.path = path
        self.systemId = systemId
        self.completion = completion
        
    }
    
    override func main() {
        
        do {
            
            let roms = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            var games = [Game]()
            
            for romPath in roms {
                
                let game = Game(romPath: systemId + "/" + romPath, systemIdentifier: systemId)
                games.append(game)
            }
            
            
            completion(games)
        }
        catch {
            
        }
        
    }
}
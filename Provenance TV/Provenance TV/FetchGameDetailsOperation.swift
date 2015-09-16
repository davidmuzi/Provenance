//
//  FetchGameDetailsOperation.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-15.
//  Copyright © 2015 Provenance. All rights reserved.
//

import Foundation

class FetchGameDetailsOperation : NSOperation {
    
    let md5: String
    let filename: String
    let completion: ((Game) -> Void)
    
    let database: OESQLiteDatabase?
    
    init(md5: String, filename: String, completion: ((Game) -> Void)) {
        self.md5 = md5
        self.filename = filename
        self.completion = completion
        
        do {
            try database = OESQLiteDatabase(URL: NSBundle.mainBundle().URLForResource("openvgdb", withExtension: "sqlite"))
        }
        catch {
            database = nil
        }
    }
    
    override func main() {
        
        // fetch details from openvgdb
        do {
            
            // SELECT DISTINCT releaseTitleName as 'gameTitle', releaseCoverFront as 'boxImageURL' FROM ROMs rom LEFT JOIN RELEASES release USING (romID) WHERE romHashMD5 = 'DBE1F3C8F3A0B2DB52B7D59417891117'
            
            //SELECT DISTINCT romFileName, releaseTitleName as 'gameTitle', releaseCoverFront as 'boxImageURL', regionName as 'region', systemShortName FROM ROMs rom LEFT JOIN RELEASES release USING (romID) LEFT JOIN SYSTEMS system USING (systemID) LEFT JOIN REGIONS region on (regionLocalizedID=region.regionID) WHERE romFileName LIKE "%Super Mario Worl%" AND systemID="26"
            
            let likeQuery = "SELECT DISTINCT romFileName, releaseTitleName as 'gameTitle', releaseCoverFront as 'boxImageURL', regionName as 'region', systemShortName FROM ROMs rom LEFT JOIN RELEASES release USING (romID) LEFT JOIN SYSTEMS system USING (systemID) LEFT JOIN REGIONS region on (regionLocalizedID=region.regionID) WHERE romFileName LIKE \"%\(filename)%\" AND systemID=\"26\""
            
            
            let results = try database?.executeQuery(likeQuery)
            
            if let results = results as? NSArray {
                
                for result in results {
                    
                    if (result["region"] == "USA") {
                        
                        if let result = result as? NSDictionary {
                            
                            var game = Game(romPath: filename, systemIdentifier: "das")
                            game.title = result["gameTitle"] as! String
                            
                            if let boxArt = result["boxImageURL"] {
                                game.originalArtworkURL = boxArt as! String
                            }
                            
                            completion(game)
                            
                            break
                        }
                    }
                }
            }
        }
        catch {
            
        }
        
    }
    
    
}
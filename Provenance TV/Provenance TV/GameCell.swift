//
//  GameCell.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-16.
//  Copyright © 2015 Provenance. All rights reserved.
//

import UIKit

class GameCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
    func update(game: Game) {
        
        let filename = (game.romPath as NSString).lastPathComponent
        let name = (filename as NSString).stringByDeletingPathExtension

        // TODO: md5 lookup
        let operation = FetchGameDetailsOperation(md5: "dsd", filename: name, systemId: game.systemIdentifier) { (game) -> Void in

            self.titleLabel!.text = game.title
            
            let imageURL = NSURL(string: game.originalArtworkURL)
            
            guard let url = imageURL else {
                return
            }
            
            NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                
                guard let imageData = data else {
                    return
                }
                
                let image = UIImage(data: imageData)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.coverImageView?.image = image
                    
                })
                
            }).resume()
        }
        
        NSOperationQueue.mainQueue().addOperation(operation)
    }
    
    
}

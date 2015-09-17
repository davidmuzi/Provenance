//
//  ViewController.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-12.
//  Copyright © 2015 Provenance. All rights reserved.
//

import UIKit

class GameListViewController: UICollectionViewController {

    var games = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let systemId = "com.provenance.snes"
        let romPath = NSBundle.mainBundle().bundlePath+"/Roms/"+systemId
        
        let operation2 = FetchGameLibraryOperation(path: romPath, systemId: systemId) { (games) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.games = games
                self.collectionView?.reloadData()
            })
            
        }
        
        NSOperationQueue.mainQueue().addOperation(operation2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: CollectionView
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GameCell
        let game = games[indexPath.row]
        
        cell.update(game)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let game = games[indexPath.row]
        let emulatorController = EmulatorViewController(game: game)

        addChildViewController(emulatorController)
        view.addSubview(emulatorController.view)
        emulatorController.didMoveToParentViewController(self)
    }
}


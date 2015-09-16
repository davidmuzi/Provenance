//
//  EmulatorViewController.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-12.
//  Copyright © 2015 Provenance. All rights reserved.
//

import UIKit

class EmulatorViewController: UIViewController {
    
    let game: Game
    let emulatorCore: PVEmulatorCore
    var batterySavesPath: String = ""
    var BIOSpath: String = ""
    var glViewController: GLViewController?
    var gameAudio: OEGameAudio?
    
    init(game: Game) {
        
        self.game = game
        
        self.emulatorCore = EmulatorConfiguration.emulatorCore(game.systemIdentifier)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        title = game.title
        view.backgroundColor = UIColor.blackColor()
        
        if configureEmulatorCore() {
            
            configureAudio()
            
            glViewController = GLViewController(emulatorCore: emulatorCore)
            addChildViewController(glViewController!)
            view.addSubview(glViewController!.view)
            glViewController!.didMoveToParentViewController(self)
        }
        
        // game details
        let filename = (game.romPath as NSString).lastPathComponent
        let name = (filename as NSString).stringByDeletingPathExtension
        
        let operation = FetchGameDetailsOperation(md5: "dsd", filename: name) { (game) -> Void in
            
            print("game \(game)")
            
        }
        
        NSOperationQueue.mainQueue().addOperation(operation)
    }

    func configureEmulatorCore() -> Bool {
     
        emulatorCore.batterySavesPath = batterySavesPath
        emulatorCore.BIOSPath = BIOSpath

        let docsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let path = docsPath.stringByAppendingPathComponent(game.romPath)
        
        if (!emulatorCore.loadFileAtPath(path)) {
            print("Could not load rom")
            return false
        }
        else {
            emulatorCore.startEmulation()
            return true
        }
    }
    
    func configureAudio() {
        
        gameAudio = OEGameAudio(core: emulatorCore)
        gameAudio!.volume = 1.0
        gameAudio!.outputDeviceID = 0
        gameAudio!.startAudio()
    }
    
    
}
//
//  ViewController.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-12.
//  Copyright © 2015 Provenance. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let game = Game(romPath: "com.provenance.snes/abc.smc", systemIdentifier: "com.provenance.snes")
        
        let emulatorController = EmulatorViewController(game: game)
        
        addChildViewController(emulatorController)
        view.addSubview(emulatorController.view)
        emulatorController.didMoveToParentViewController(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  EmulatorConfiguration.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-12.
//  Copyright © 2015 Provenance. All rights reserved.
//

import Foundation

class EmulatorConfiguration {
    
    static func emulatorCore(systemIdentifier: String) -> PVEmulatorCore  {
        
        // support snes only, for now
        return PVSNESEmulatorCore()
    }
}

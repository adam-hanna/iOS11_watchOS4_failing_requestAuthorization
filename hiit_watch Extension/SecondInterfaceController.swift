//
//  SecondInterfaceController.swift
//  watch_test Extension
//
//  Created by Adam Hanna on 11/20/17.
//  Copyright © 2017 Adam Hanna. All rights reserved.
//

import WatchKit
import Foundation

class SecondInterfaceController: WKInterfaceController {
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("SecondInterfaceController - awakeWithContext")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be
        // visible to user
        super.willActivate()
        print("SecondInterfaceController - willActivate")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer
        // visible
        super.didDeactivate()
        print("SecondInterfaceController - didDeactivate")
    }
    
}

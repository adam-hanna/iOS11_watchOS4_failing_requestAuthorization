//
//  ViewController.swift
//  test
//
//  Created by Adam Hanna on 11/12/17.
//  Copyright © 2017 Adam Hanna. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    @IBOutlet weak var wachMessageDisplay: UILabel!
    var watchMessage = [String]()
    var session: WCSession!
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session; err: \(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session did de-activate")
    }
    
    // handle messages from the watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let watchMessage = message["watchMessage"] as? String
        print("Got a message from watch! Message: \(String(describing: watchMessage))")
        
        // Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async() {
            self.wachMessageDisplay.text = watchMessage!
        }
        
        // let replyData = ["watchMessage":String("Hello from the Phone reply!")]
        // replyHandler(replyData as [String : AnyObject])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // start watch session
        if (WCSession.isSupported()) {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


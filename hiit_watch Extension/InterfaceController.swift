//
//  InterfaceController.swift
//  watch_test Extension
//
//  Created by Adam Hanna on 11/12/17.
//  Copyright © 2017 Adam Hanna. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var levelString: WKInterfaceLabel!
    var session : WCSession!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // start comms with main app
        if (WCSession.isSupported()) {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
            
            // send it a message
            let applicationData = ["watchMessage":String("Hello from the watch!")]
            
            self.session.sendMessage(applicationData, replyHandler: {(replyDict) -> Void in
                // handle reply from iPhone app here
                print(replyDict)
            }, errorHandler: {(error ) -> Void in
                // catch any errors here
                print("Error sending message to app \(error)")
            })
        }
        
        // handle message from phone
        func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
            //recieving message from iphone
            print("recieved message from iphone \(message)")
        }
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                let defaultAction = WKAlertAction(
                    title: "Ok",
                    style: WKAlertActionStyle.default) { () -> Void in
                        print("Default")
                }
                self.presentAlert(
                    withTitle: "Error",
                    message: "Healthkit not authorized",
                    preferredStyle: WKAlertControllerStyle.alert,
                    actions: [defaultAction]
                )
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
            
            // note @adam-hanna: check HKHealthStore.isHealthDataAvailable()?
            let healthStore = HKHealthStore()
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .highIntensityIntervalTraining
            configuration.locationType = .indoor
            
            do {
                let session = try HKWorkoutSession(configuration: configuration)
                
                // session.delegate = self
                healthStore.start(session)
                
                // This is the type you want updates on. It can be any health kit type, including heart rate.
                let heartRateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
                
                // Match samples with a start date after the workout start
                let predicate = HKQuery.predicateForSamples(withStart: session.startDate, end: nil, options: [])
                
                // var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
                let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType!, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit), resultsHandler: { (query, sampleObjects, deletedObjects, newAnchor, error) in
                    // Do anchor code here
                    // guard let newAnchor = newAnchor else {return}
                    // anchor = newAnchor
                    
                    self.updateHeartRate(samples: sampleObjects)
                })
                
                // This is called each time a new value is entered into HealthKit (samples may be batched together for efficiency)
                heartRateQuery.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
                    // Handle update notifications after the query has initially run
                    // TODO: do whatever you want with samples (note you are not on the main thread)
                    self.updateHeartRate(samples: samples)
                }
                
                // Start the query
                healthStore.execute(heartRateQuery)
            }
            catch let error as NSError {
                // Perform proper error handling here...
                fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        DispatchQueue.main.async() {
            guard let sample = heartRateSamples.first else{return}
            let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = sample.quantity.doubleValue(for: heartRateUnit)
            let zone = Zone(fromHeartRate: value)
            
            self.levelString.setText(zone.LevelString())
            self.label.setText(String(UInt16(value)))
            self.label.setTextColor(zone.Color)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
    }

}

//
//  ExtensionDelegate.swift
//  watch_test Extension
//
//  Created by Adam Hanna on 11/12/17.
//  Copyright © 2017 Adam Hanna. All rights reserved.
//

import WatchKit
import HealthKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    private var numAuthTries = 0
    private let maxAuthTries = 5

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        // request healthkit auth and start workout session
        HealthKitSetupAssistant.authorizeHealthKit(completion: self.authorizeHealthkitCB)
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                if #available(watchOSApplicationExtension 4.0, *) {
                    backgroundTask.setTaskCompletedWithSnapshot(false)
                } else {
                    // Fallback on earlier versions
                }
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                if #available(watchOSApplicationExtension 4.0, *) {
                    connectivityTask.setTaskCompletedWithSnapshot(false)
                } else {
                    // Fallback on earlier versions
                }
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                if #available(watchOSApplicationExtension 4.0, *) {
                    urlSessionTask.setTaskCompletedWithSnapshot(false)
                } else {
                    // Fallback on earlier versions
                }
            default:
                // make sure to complete unhandled task types
                if #available(watchOSApplicationExtension 4.0, *) {
                    task.setTaskCompletedWithSnapshot(false)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    private func authorizeHealthkitCB(authorized: Bool, error: Error?) -> Void {
        print("Authorized: \(authorized).")
        print("Error: \(String(describing: error)).")
    
        guard authorized else {
    
            let baseMessage = "HealthKit Authorization Failed"
        
            if let error = error {
                print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
                print(baseMessage)
            }
            
            self.numAuthTries += 1
            print("numAuthTries: \(numAuthTries)")
            if self.numAuthTries <= self.maxAuthTries {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    // Put your code which should be executed with a delay here
                    HealthKitSetupAssistant.authorizeHealthKit(completion: self.authorizeHealthkitCB)
                })
            } else {
                // note @adam-hanna: how to display an error to the user?
                //                let defaultAction = WKAlertAction(
                //                    title: "Ok",
                //                    style: WKAlertActionStyle.default) { () -> Void in
                //                        print("Default")
                //                }
                //                self.presentAlert(
                //                    withTitle: "Error",
                //                    message: "Healthkit not authorized",
                //                    preferredStyle: WKAlertControllerStyle.alert,
                //                    actions: [defaultAction]
                //                )
            }
    
            return
        }
    
        print("HealthKit Successfully Authorized.")
    
        // note @adam-hanna: check HKHealthStore.isHealthDataAvailable()?
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .highIntensityIntervalTraining
        configuration.locationType = .indoor
    
        do {
            let session = try HKWorkoutSession(configuration: configuration)
            SharedHealthStoreSingleton.start(workoutSession: session)
        }
        catch let error as NSError {
            // Perform proper error handling here...
            fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
        }
    }

}

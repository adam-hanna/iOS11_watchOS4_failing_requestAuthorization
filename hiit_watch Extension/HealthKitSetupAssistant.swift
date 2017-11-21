//
//  HealthKitSetupAssistant.swift
//  watch_test Extension
//
//  Created by Adam Hanna on 11/13/17.
//  Copyright © 2017 Adam Hanna. All rights reserved.
//

// from: https://www.raywenderlich.com/159019/healthkit-tutorial-swift-getting-started

import Foundation
import HealthKit

class HealthKitSetupAssistant {
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        // 1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        // 2. Prepare the data types that will interact with HealthKit
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        // 3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]
        
        let healthKitTypesToRead: Set<HKObjectType> = [
            heartRate,
            HKObjectType.workoutType()
        ]
        
        // 4. Request Authorization
        SharedHealthStoreSingleton.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead, completion: completion)
    }
}

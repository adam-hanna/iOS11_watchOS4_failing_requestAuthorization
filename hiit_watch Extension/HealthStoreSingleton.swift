//
//  healthStoreSingleton.swift
//  watch_test Extension
//
//  Created by Adam Hanna on 11/20/17.
//  Copyright © 2017 Adam Hanna. All rights reserved.
//

import Foundation
import HealthKit

// note: singletons are frowned upon but healthkit docs state that only one hkstore should be initialized
public var SharedHealthStoreSingleton = Store.shared
public final class Store {
    private var healthStore: HKHealthStore
    private var workoutSession: HKWorkoutSession?
    private var workSessionDidStartCB: () -> Void = {print("work session did start")}
    
    // Singleton. i.e. only one can exist!
    static let shared: Store = Store()
    private init() {
        self.healthStore = HKHealthStore()
    }
    
    public func start(workoutSession: HKWorkoutSession) {
        self.workoutSession = workoutSession
        self.healthStore.start(workoutSession)
        self.workSessionDidStartCB()
    }
    
    public func execute(query: HKQuery) {
        self.healthStore.execute(query)
    }
    
    public func getSessionStart() -> Date {
        let now = Date()
        
        if self.workoutSession == nil {
            return now
        } else if self.workoutSession!.startDate == nil {
            return now
        }
        
        return self.workoutSession!.startDate!
    }
    
    public func hasWorkSessionStarted() -> Bool {
        let ws = (self.workoutSession ?? nil)
        return ws != nil
    }
    
    public func setWorkSessionCB(cb: @escaping () -> Void) {
        self.workSessionDidStartCB = cb
    }
    
    public func requestAuthorization(toShare: Set<HKSampleType>, read: Set<HKObjectType>, completion: @escaping (Bool, Error?) -> Void) {
        self.healthStore.requestAuthorization(
            toShare: toShare,
            read: read,
            completion: completion
        )
    }

}

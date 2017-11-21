//
//  heartRateLevel.swift
//  watch_test Extension
//
//  Created by Adam Hanna on 11/14/17.
//  Copyright © 2017 Adam Hanna. All rights reserved.
//

import Foundation
import UIKit

enum Level {
    case WarmUp
    case AerobicLight
    case AerobicEndurance
    case AnaerobicPerformance
    case AnaerobicRedLine
}

struct Zone {
    let L: Level
    let Color: UIColor
    
    init(fromHeartRate rate: Double) {
        switch rate {
        case _ where rate < 65.21:
            L = .WarmUp
            Color = UIColor(red: 4/255, green: 104/255, blue: 200/255, alpha: 1.0)
        case _ where rate < 78.25:
            L = .AerobicLight
            Color = UIColor(red: 3/255, green: 163/255, blue: 91/255, alpha: 1.0)
        case _ where rate < 91.29:
            L = .AerobicEndurance
            Color = UIColor(red: 252/255, green: 240/255, blue: 3/255, alpha: 1.0)
        case _ where rate < 104.33:
            L = .AnaerobicPerformance
            Color = UIColor(red: 245/255, green: 132/255, blue: 39/255, alpha: 1.0)
        default:
            L = .AnaerobicRedLine
            Color = UIColor(red: 235/255, green: 30/255, blue: 37/255, alpha: 1.0)
        }
    }
    
    func LevelString() -> String {
        switch L {
        case .WarmUp:
            return "Warm Up"
        case .AerobicLight:
            return "Aerobic Light"
        case .AerobicEndurance:
            return "Aerobic Endurance"
        case .AnaerobicPerformance:
            return "Anaerobic Performance"
        case .AnaerobicRedLine:
            return "Anaerobic Red Line"
        }
    }
}

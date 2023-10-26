//
//  TimeInterval+Extension.swift
//  
//
//  Created by Florian Zand on 26.10.23.
//

import Foundation
import QuartzCore

public extension TimeInterval {
    /// The current time interval in seconds.
    static var now: TimeInterval {
        return CACurrentMediaTime()
    }
}

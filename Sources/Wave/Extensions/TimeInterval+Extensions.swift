//
//  TimeInterval+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

extension TimeInterval {
    static var now: TimeInterval {
        return CACurrentMediaTime()
    }
}

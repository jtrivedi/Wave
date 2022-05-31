//
//  CGPoint+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

public extension CGPoint {

    /**
     Returns a point value whose `x`/`y` components are rounded to the nearest pixel boundary,
     taking into account the device's display scale.
     */
    var scaledIntegral: CGPoint {
        CGPoint(x: x.scaledIntegral, y: y.scaledIntegral)
    }

    /**
     The absolute, positive distance another `CGPoint`.
     - parameter to: The other point.
     */
    func distance(to point: CGPoint) -> CGFloat {
        let distanceSquared = (x - point.x) * (x - point.x) + (y - point.y) * (y - point.y)
        return sqrt(distanceSquared)
    }

    // MARK: - Operators

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

}

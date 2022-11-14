//
//  CGPoint+Extensions.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

extension CGPoint {

    /**
     Returns a point value whose `x`/`y` components are rounded to the nearest pixel boundary,
     taking into account the device's display scale.
     */
    public var scaledIntegral: CGPoint {
        CGPoint(x: x.scaledIntegral, y: y.scaledIntegral)
    }

    /**
     The absolute, positive distance another `CGPoint`.
     - parameter to: The other point.
     */
    public func distance(to point: CGPoint) -> CGFloat {
        let distanceSquared = (x - point.x) * (x - point.x) + (y - point.y) * (y - point.y)
        return sqrt(distanceSquared)
    }

}

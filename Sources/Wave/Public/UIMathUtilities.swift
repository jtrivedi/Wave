//
//  UIMathUtilities.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import UIKit

public func rubberband(value: CGFloat, range: ClosedRange<CGFloat>, interval: CGFloat, c: CGFloat = 0.55) -> CGFloat {
    // * x = distance from the edge
    // * c = constant value, UIScrollView uses 0.55
    // * d = dimension, either width or height
    // b = (1.0 – (1.0 / ((x * c / d) + 1.0))) * d
    if range.contains(value) {
        return value
    }

    let d: CGFloat = interval

    if value > range.upperBound {
        let x = value - range.upperBound
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        return range.upperBound + b
    } else {
        let x = range.lowerBound - value
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        return range.lowerBound - b
    }
}

/**
 Projects a scalar value based on a scalar velocity.
 */
public func project(value: CGFloat, velocity: CGFloat, decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue) -> CGFloat {
    value + project(initialVelocity: velocity, decelerationRate: decelerationRate)
}

/**
 Projects a 2D point based on a 2D velocity.
 */
public func project(point: CGPoint, velocity: CGPoint, decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue) -> CGPoint {
    CGPoint(
        x: point.x + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
        y: point.y + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
    )
}

func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
    (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
}

/**
 Takes a value in range `(a, b)` and returns that value mapped to another range `(c, d)` using linear interpolation.
 
 For example, `0.5` mapped from range `(0, 1)` to range `(0, 100`) would produce `50`.
 
 Note that the return value is not clipped to the `out` range. For example, `mapRange(2, 0, 1, 0, 100)` would return `200`.
 */
public func mapRange<T: FloatingPoint>(value: T, inMin: T, inMax: T, outMin: T, outMax: T, clip: Bool = false) -> T {
    let result = ((value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin)
    if clip {
        if result > outMax {
            return outMax
        } else if result < outMin {
            return outMin
        } else {
            return result
        }
    } else {
        return result
    }
}

/**
 The same function as `mapRange(value:inMin:inMax:outMin:outMax:)` but omitting the parameter names for terseness.
 */
public func mapRange<T: FloatingPoint>(_ value: T, _ inMin: T, _ inMax: T, _ outMin: T, _ outMax: T, clip: Bool = false) -> T {
    mapRange(value: value, inMin: inMin, inMax: inMax, outMin: outMin, outMax: outMax, clip: clip)
}

/**
 Returns a value bounded by the provided range.
 - parameter lower: The minimum allowable value (inclusive).
 - parameter upper: The maximum allowable value (inclusive).
 */
public func clip<T: FloatingPoint>(value: T, lower: T, upper: T) -> T {
    min(upper, max(value, lower))
}

/**
 Returns a value bounded by the range `[0, 1]`.
 */
public func clipUnit<T: FloatingPoint>(value: T) -> T {
    clip(value: value, lower: 0, upper: 1)
}

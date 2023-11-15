//
//  Spring.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import CoreGraphics
import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

/**
 `Spring` determines the timing curve and settling duration of an animation.

 Springs are created by providing a `dampingRatio` greater than zero, and _either_ a ``response`` or ``stiffness`` value. See the initializers ``init(dampingRatio:response:mass:)`` and ``init(dampingRatio:stiffness:mass:)`` for usage information.
 */
public struct Spring: Equatable {
    // MARK: - Spring Properties

    /// The amount of oscillation the spring will exhibit (i.e. "springiness").
    public let dampingRatio: CGFloat

    /// The stiffness of the spring, defined as an approximate duration in seconds.
    public let response: CGFloat

    /// The spring stiffness coefficient. Increasing the stiffness reduces the number of oscillations and will reduce the settling duration.
    public let stiffness: CGFloat

    /// The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
    public let mass: CGFloat

    /// Defines how the spring’s motion should be damped due to the forces of friction.
    public let damping: CGFloat

    /// The estimated duration required for the spring system to be considered at rest.
    public let settlingDuration: TimeInterval

    
    // MARK: - Spring Initialization
    
    /**
     Creates a spring with the specified duration and bounce.
     
     - Parameters:
        - duration: Defines the pace of the spring. This is approximately equal to the settling duration, but for springs with very large bounce values, will be the duration of the period of oscillation for the spring.
        - bounce: How bouncy the spring should be. A value of 0 indicates no bounces (a critically damped spring), positive values indicate increasing amounts of bounciness up to a maximum of 1.0 (corresponding to undamped oscillation), and negative values indicate overdamped springs with a minimum value of -1.0.
     */
    public init(duration: CGFloat = 0.5, bounce: CGFloat = 0.0) {
        self.init(dampingRatio: 1.0 - bounce, response: duration, mass: 1.0)
    }

    /**
     Creates a spring with the given damping ratio and frequency response.

     - Parameters:
        - dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness"). A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation. Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.
        - stiffness: Represents the spring constant, `k`. This value affects how quickly the spring animation reaches its target value.  Using `stiffness` values is an alternative to configuring springs with a `response` value.
        - mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public init(dampingRatio: CGFloat, stiffness: CGFloat, mass: CGFloat = 1.0) {
        precondition(stiffness > 0)
        precondition(dampingRatio > 0)

        self.dampingRatio = dampingRatio
        self.stiffness = stiffness
        self.mass = mass
        self.response = Spring.response(stiffness: stiffness, mass: mass)
        self.damping = Spring.damping(dampingRatio: dampingRatio, response: response, mass: mass)
        self.settlingDuration = Spring.settlingTime(dampingRatio: dampingRatio, stiffness: stiffness, mass: mass)
    }

    /**
     Creates a spring with the given damping ratio and frequency response.

     - parameters:
        - dampingRatio: The amount of oscillation the spring will exhibit (i.e. "springiness"). A value of `1.0` (critically damped) will cause the spring to smoothly reach its target value without any oscillation. Values closer to `0.0` (underdamped) will increase oscillation (and overshoot the target) before settling.
        - response: Represents the frequency response of the spring. This value affects how quickly the spring animation reaches its target value. The frequency response is the duration of one period in the spring's undamped system, measured in seconds. Values closer to `0` create a very fast animation, while values closer to `1.0` create a relatively slower animation.
        - mass: The mass "attached" to the spring. The default value of `1.0` rarely needs to be modified.
     */
    public init(dampingRatio: CGFloat, response: CGFloat, mass: CGFloat = 1.0) {
        precondition(dampingRatio >= 0)
        precondition(response >= 0)

        self.dampingRatio = dampingRatio
        self.response = response
        self.mass = mass
        self.stiffness = Spring.stiffness(response: response, mass: mass)

        let unbandedDampingCoefficient = Spring.damping(dampingRatio: dampingRatio, response: response, mass: mass)
        self.damping = rubberband(value: unbandedDampingCoefficient, range: 0 ... 60, interval: 15)

        self.settlingDuration = Spring.settlingTime(dampingRatio: dampingRatio, stiffness: stiffness, mass: mass)
    }
    
    /**
     Creates a spring with the specified mass, stiffness, and damping.
     
     - Parameters:
     - damping: The corresponding spring coefficient.
        - stiffness: Specifies that property of the object attached to the end of the spring.
        - mass: Defines how the spring’s motion should be damped due to the forces of friction.
        - allowOverDamping: A value of `true` specifies that over-damping should be allowed when appropriate based on the other inputs, and a value of `false` specifies that such cases should instead be treated as critically damped.
     */
    public init (damping: CGFloat, stiffness: CGFloat, mass: CGFloat = 1.0, allowOverDamping: Bool = false) {
        var dampingRatio = Self.dampingRatio(damping: damping, stiffness: stiffness, mass: mass)
        if allowOverDamping == false, dampingRatio > 1.0 {
            dampingRatio = 1.0
        }
        self.init(dampingRatio: dampingRatio, stiffness: stiffness, mass: mass)
    }
    
    
    @available(macOS 14.0, iOS 17, tvOS 17, *)
    /// Creates a spring from the values of the specified SwiftUI spring.
    public init(_ spring: SwiftUI.Spring) {
        dampingRatio = spring.dampingRatio
        response = spring.response
        stiffness = spring.stiffness
        mass = spring.mass
        damping = spring.damping
        settlingDuration = spring.settlingDuration
    }
    
    /**
     Creates a spring with the specified duration and damping ratio.
     
     - Parameters:
        - settlingDuration: The approximate time it will take for the spring to come to rest.
        - dampingRatio: The amount of drag applied as a fraction of the amount needed to produce critical damping.
        - epsilon: The threshhold for how small all subsequent values need to be before the spring is considered to have settled.
     */
    @available(macOS 14.0, iOS 17, tvOS 17, *)
    public init(settlingDuration: TimeInterval, dampingRatio: Double, epsilon: Double = 0.001) {
        let spring = SwiftUI.Spring(settlingDuration: settlingDuration, dampingRatio: dampingRatio, epsilon: epsilon)
        self.init(spring)
    }

    // MARK: - Default Springs

    /// A reasonable, slightly underdamped spring to use for interactive animations (like dragging an item around).
    public static let interactive = Spring(dampingRatio: 0.8, response: 0.28)

    /// A non animated spring which updates values immediately.
    public static let nonAnimated = Spring(dampingRatio: 1.0, response: 0.0)
    
    
    /// A spring with a predefined duration and higher amount of bounce.
    public static let bouncy = Spring.bouncy()
    
    /**
     A spring with a predefined duration and higher amount of bounce that can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.3.
     */
    public static func bouncy(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> Spring {
        Spring(dampingRatio: 0.7-extraBounce, response: duration, mass: 1.0)
    }
    
    /// A smooth spring with a predefined duration and no bounce.
    public static let smooth = Spring.smooth()
    
    /**
     A smooth spring with a predefined duration and no bounce that can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.
     */
    public static func smooth(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> Spring {
        Spring(dampingRatio: 1.0-extraBounce, response: duration, mass: 1.0)
    }
    
    /// A spring with a predefined duration and small amount of bounce that feels more snappy.
    public static let snappy = Spring.snappy()
    
    /**
     A spring with a predefined duration and small amount of bounce that feels more snappy and can be tuned.
     
     - Parameters:
        - duration: The perceptual duration, which defines the pace of the spring. This is approximately equal to the settling duration, but for very bouncy springs, will be the duration of the period of oscillation for the spring.
        - extraBounce: How much additional bounciness should be added to the base bounce of 0.15.
     */
    public static func snappy(duration: CGFloat = 0.5, extraBounce: CGFloat = 0.0) -> Spring {
        return Spring(dampingRatio: 0.85-extraBounce, response: duration, mass: 1.0)
    }
    
    // MARK: - Updating values

    /// Updates the current value and velocity of a spring.
    public func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V : VectorArithmetic {
        let displacement = value - target
        let springForce = displacement * -self.stiffness
        let dampingForce = velocity.scaled(by: self.damping)
        let force = springForce - dampingForce
        let acceleration = force * (1.0 / self.mass)
        
        velocity = velocity + (acceleration * deltaTime)
        value = value + (velocity * deltaTime)
    }
    
    /// Updates the current value and velocity of a spring.
    public func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V : AnimatableData {
        var valueData = value.animatableData
        var velocityData = velocity.animatableData
        
        self.update(value: &valueData, velocity: &velocityData, target: target.animatableData, deltaTime: deltaTime)
        velocity = V(velocityData)
        value = V(valueData)
    }
    

    // MARK: - Spring calculation

    public static func == (lhs: Spring, rhs: Spring) -> Bool {
        return lhs.dampingRatio == rhs.dampingRatio && lhs.response == rhs.response && lhs.mass == rhs.mass
    }

    static func stiffness(response: CGFloat, mass: CGFloat) -> CGFloat {
        pow(2.0 * .pi / response, 2.0) * mass
    }

    static func response(stiffness: CGFloat, mass: CGFloat) -> CGFloat {
        (2.0 * .pi) / sqrt(stiffness * mass)
    }

    static func damping(dampingRatio: CGFloat, response: CGFloat, mass: CGFloat) -> CGFloat {
        4.0 * .pi * dampingRatio * mass / response
    }
    
    static func dampingRatio(damping: CGFloat, stiffness: CGFloat, mass: CGFloat) -> CGFloat {
        return damping / (2 * sqrt(stiffness * mass))
    }

    static func settlingTime(dampingRatio: CGFloat, stiffness: CGFloat, mass: CGFloat) -> CGFloat {
        if stiffness == .infinity {
            // A non-animated mode (i.e. a `response` of 0) results in a stiffness of infinity, and a settling time of 0.
            // We need the settling time to be non-zero such that the display link stays alive.
            return 1.0
        }

        if dampingRatio >= 1.0 {
            let criticallyDampedSettlingTime = settlingTime(dampingRatio: 1.0 - .ulpOfOne, stiffness: stiffness, mass: mass)
            return criticallyDampedSettlingTime * 1.25
        }

        let undampedNaturalFrequency = Spring.undampedNaturalFrequency(stiffness: stiffness, mass: mass) // ωn
        return (-1 * (logOfSettlingPercentage / (dampingRatio * undampedNaturalFrequency)))
    }
    
    internal static let DefaultSettlingPercentage = 0.0001
    static let logOfSettlingPercentage = log(Spring.DefaultSettlingPercentage)

    static func undampedNaturalFrequency(stiffness: CGFloat, mass: CGFloat) -> CGFloat {
        return sqrt(stiffness / mass)
    }
}


extension Spring: CustomStringConvertible {
    public var description: String {
        """
        Spring(
            // Parameters
            dampingRatio: \(dampingRatio)
            response: \(response)
            mass: \(mass)

            // Derived
            settlingDuration: \(String(format: "%.3f", settlingDuration))
            stiffness: \(String(format: "%.3f", stiffness))
            animated: \(response != .zero)
        )
        """
    }
}


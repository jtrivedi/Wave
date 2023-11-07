//
//  CAKeyframeAnimationEmittable.swift
//
//  Copyright (c) 2020, Adam Bell
//  Modifed:
//  Florian Zand on 02.11.23.
//

import Foundation
import QuartzCore
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

// MARK: - CAKeyframeAnimationEmittable

/// A type that defines the ability to generate a `CAKeyframeAnimation` from an animation.
public protocol CAKeyframeAnimationEmittable  {
    /**
     Generates and returns a `CAKeyframeAnimation` based on the animation's current value targeting the animation's target value.

     - Parameters:
        - framerate: The framerate the `CAKeyframeAnimation` should be targeting. If nil, the device's default framerate will be used.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from the current animation's state to its resolved state.
     - Note: You will be required to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to be useful.

     ```
     let animation = SpringAnimator(spring: .bouncy, value: 0.0, target: 100.0)

     let keyframeAnimation = animation.keyframeAnimation()
     keyFrameAnimation.keyPath = "position.y"
     layer.add(keyFrameAnimation, forKey: "animation")
     ```
     */
    func keyframeAnimation(forFramerate framerate: Int?) -> CAKeyframeAnimation

    /**
     Generates and returns the values and keyTimes for a `CAKeyframeAnimation`. This is called by default from `keyframeAnimation(forFramerate:)`.

     - Parameters:
        - deltaTime: The target delta time. Typically you'd want 1.0 / targetFramerate`
        - values: A preinitialized array that should be populated with the values to align with the given keyTimes.
        - keyTimes: A preinitialized array that should be populated with the keyTimes to align with the given values.

     - Returns: The total duration of the `CAKeyframeAnimation`.

     - Note: Returning values and keyTimes with different lengths will result in undefined behaviour.
     */
    func populateKeyframeAnimationData(deltaTime: TimeInterval, values: inout [AnyObject], keyTimes: inout [NSNumber]) -> TimeInterval

}

extension CAKeyframeAnimationEmittable {
    public func keyframeAnimation(forFramerate framerate: Int? = nil) -> CAKeyframeAnimation {
        let deltaTime: TimeInterval
        if let framerate = framerate {
            deltaTime = 1.0 / TimeInterval(framerate)
        } else {
            #if os(macOS)
            deltaTime = 1.0 / TimeInterval(NSScreen.current?.preferredFramesPerSecond ?? 60)
            #else
            deltaTime = 1.0 / TimeInterval(UIScreen.current?.preferredFramesPerSecond ?? 60)
            #endif
        }

        var values = [AnyObject]()
        var keyTimes = [NSNumber]()

        let duration = populateKeyframeAnimationData(deltaTime: deltaTime, values: &values, keyTimes: &keyTimes)

        let keyframeAnimation = CAKeyframeAnimation()
        keyframeAnimation.calculationMode = .discrete
        keyframeAnimation.values = values
        keyframeAnimation.keyTimes = keyTimes
        keyframeAnimation.duration = duration
        return keyframeAnimation
    }
    
    #if os(macOS)
    /**
     Generates and returns a `CAKeyframeAnimation` based on the animation's current value targeting the animation's target value.

     - Parameters:
        - screen: The screen where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from the current animation's state to its resolved state.
     - Note: You will be required to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to be useful.
     */
    public func keyframeAnimation(forScreen screen: NSScreen) -> CAKeyframeAnimation {
        return keyframeAnimation(forFramerate: screen.preferredFramesPerSecond)
    }
    #else
    /**
     Generates and returns a `CAKeyframeAnimation` based on the animation's current value targeting the animation's target value.

     - Parameters:
        - screen: The screen where the animation is displayed.
     - Returns: A fully configured `CAKeyframeAnimation` which represents the animation from the current animation's state to its resolved state.
     - Note: You will be required to change the `keyPath` of the `CAKeyFrameAnimation` in order for it to be useful.
     */
    public func keyframeAnimation(forScreen screen: UIScreen) -> CAKeyframeAnimation {
        return keyframeAnimation(forFramerate: screen.preferredFramesPerSecond)
    }
    #endif
}

extension SpringAnimator: CAKeyframeAnimationEmittable where T: CAKeyframeAnimationValueConvertible {
    /// Generates and populates the `values` and `keyTimes` for a given `SpringAnimator` animating from its ``value`` to its ``target`` by ticking it by `deltaTime` until it resolves.
    public func populateKeyframeAnimationData(deltaTime: TimeInterval, values: inout [AnyObject], keyTimes: inout [NSNumber]) -> TimeInterval {
        guard var value = value, let target = target else { return 0.0 }
        var velocity = velocity

        var t = 0.0
        var hasResolved = false
        while !hasResolved {
            spring.update(value: &value, velocity: &velocity, target: target, deltaTime: deltaTime)
            
            values.append(value.toKeyframeValue())
            keyTimes.append(t as NSNumber)

            t += deltaTime
            
            let isAnimated = spring.response > .zero
            hasResolved = (t >= settlingTime) || !isAnimated
        }
        
        values.append(target.toKeyframeValue())
        keyTimes.append(t as NSNumber)

        return t
    }
}

#if os(macOS)
fileprivate extension NSScreen {
    var preferredFramesPerSecond: Int {
        guard #available(macOS 12.0, *) else { return 60 }
        let fps = maximumFramesPerSecond
        guard fps > 0 else { return 60 }
        return fps
    }
    
    static var current: NSScreen? {
        NSScreen.main
    }
}
#elseif canImport(UIKit)
fileprivate extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
    
    var preferredFramesPerSecond: Int {
        let fps = maximumFramesPerSecond
        guard fps > 0 else { return 60 }
        return fps
    }
}

fileprivate extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}
#endif

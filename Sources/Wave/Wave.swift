//
//  Wave.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import QuartzCore
import SwiftUI

public enum Wave {
    /**
     Performs animations based on the `Spring` value provided.
     
     The following objects provide animatable properties via `animator`.
     - macOS: `NSView`, `NSTextField`, `NSWindow`, `NSLayoutConstraint` and `CALayer`.
     - iOS: `UIView`, `UITextField`, `UILabel`, `NSLayoutConstraint` and `CALayer`.

     Note: For animations to work correctly, you must set values on the objects's `animator`, not just the object itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`
          
     ```swift
     Wave.animateWith(spring: Spring(dampingRatio: 0.6, response: 1.2)) {
        myView.animator.center = view.center
        myView.animator.backgroundColor = .systemBlue
     }
     ```
     - Parameters:
        - spring: The `Spring` used to determine the timing curve and duration of the animation. The default spring is `snappy`.
        - delay: An optional delay, in seconds, after which to start the animation.
        - gestureVelocity: If provided, this value will be used to set the `velocity` of whatever underlying animations run in the `animations` block. This should be primarily used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.
        - animations: A block containing the changes to your objects' animatable properties. Note that for animations to work correctly, you must set values on the object's `animator`, not just the object itself.
        - completion: A block to be executed when the specified animations have either finished or retargeted to a new value.
     */
    public static func animate(
        withSpring spring: Spring,
        delay: TimeInterval = 0,
        gestureVelocity: CGPoint? = nil,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread)
        
        let settings = AnimationController.AnimationParameters(
            groupUUID: UUID(),
            spring: spring,
            delay: delay,
            gestureVelocity: gestureVelocity,
            completion: completion
        )
        
        AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
    
    /// Performs the specified changes non animated.
    public static func nonAnimate(changes: () -> Void) {
        self.animate(withSpring: .nonAnimated, animations: changes)
    }
}

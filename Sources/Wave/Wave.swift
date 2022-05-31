//
//  Wave.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

public class Wave {

    // MARK: - Block-Based Animation

    /**
     Performs animations based on the `Spring` value provided.
     
     **Note**: For animations to work correctly, you must set values on the view's `animator`, not just the view itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.
     
     For a full list of the various `UIView` animatable properties that Wave supports, see `ViewAnimator`.
     
     **Example Usage:**
     ```
     let box = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
     view.addSubview(box)
     box.backgroundColor = .systemMint
     
     Wave.animateWith(spring: Spring(dampingRatio: 0.6, response: 1.2)) {
         box.animator.center = view.center
         box.animator.backgroundColor = .systemBlue
     }
     ```
     
     - parameter spring: The `Spring` used to determine the timing curve and duration of the animation. See the initializer `Spring(dampingRatio:response:mass)` for more information on how to choose relevant spring values.
     
     - parameter mode: _Optional_. Determines if the `animations` block will be run with animation (default), or non-animatedly. See `AnimationMode` for information on when to use a non-animated mode.
     
     - parameter delay: _Optional_.  A delay, in seconds, after which to start the animation.
     
     - parameter gestureVelocity: _Optional_. If provided, this value will be used to set the `velocity` of whatever underlying animations run in the `animations` block. This should be primarily used to "inject" the velocity of a gesture recognizer (when the gesture ends) into the animations.
     
     - parameter animations: A block containing the changes to your views' animatable properties. Note that for animations to work correctly, you must set values on the view's `animator`, not just the view itself. For example, to animate a view's alpha, use `myView.animator.alpha = 1.0` instead of `myView.alpha = 1.0`.
     
     - parameter completion: A block to be executed when the specified animations have either finished _or_ retargeted to a new value.
     */
    public static func animate(
        withSpring spring: Spring,
        mode: AnimationMode = .animated,
        delay: TimeInterval = 0,
        gestureVelocity: CGPoint? = nil,
        animations: (() -> Void),
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil) {
            precondition(Thread.isMainThread)

            let settings = AnimationController.AnimationParameters(
                groupUUID: UUID(),
                spring: (mode == .none) ? .defaultNonAnimated : spring,
                mode: (spring.response == 0) ? .nonAnimated : mode,
                delay: delay,
                gestureVelocity: gestureVelocity,
                completion: completion
            )

            AnimationController.shared.runAnimationBlock(settings: settings, animations: animations, completion: completion)
    }
}

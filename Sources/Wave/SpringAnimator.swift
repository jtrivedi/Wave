//
//  SpringAnimator.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import QuartzCore

import Foundation

public class SpringAnimator<T: AnimatableData>: AnimatorProviding   {
    /**
     A unique identifier for the animation.
     */
    public let id = UUID()

    /**
     The execution state of the animation (`inactive`, `running`, or `ended`).
     */
    public private(set) var state: AnimatorState = .inactive {
        didSet {
            switch (oldValue, state) {
            case (.inactive, .running):
                startTime = .now

            default:
                break
            }
        }
    }

    /**
     The spring model that determines the animation's motion.
     */
    public var spring: Spring

    /**
     The _current_ value of the animation. This value will change as the animation executes.

     `value` needs to be set to a non-nil value before the animation can start.
     */
    public var value: T?

    /**
     The current target value of the animation.

     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: T? {
        didSet {
            guard let oldValue = oldValue, let newValue = target else {
                return
            }

            if oldValue == newValue {
                return
            }

            if state == .running {
                startTime = .now

                let event = AnimationEvent.retargeted(from: oldValue, to: newValue)
                completion?(event)
            }
        }
    }

    /**
     The current velocity of the animation.

     If animating a view's `center` or `frame` with a gesture, you may want to set `velocity` to the gesture's final velocity on touch-up.
     */
    public var velocity: T

    /**
     The callback block to call when the animation's `value` changes as it executes. Use the `currentValue` to drive your application's animations.
     */
    public var valueChanged: ((_ currentValue: T) -> Void)?

    /**
     The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     */
    public var completion: ((_ event: AnimationEvent<T>) -> Void)?

    /**
     The animation's `mode`. If set to `.nonAnimated`, the animation will snap to the target value when run.
     */
   // public var mode: Wave.AnimationMode = .animated

    /**
     Whether the values returned in `valueChanged` should be integralized to the screen's pixel boundaries.
     This helps prevent drawing frames between pixels, causing aliasing issues.

     Note: Enabling `integralizeValues` effectively quantizes `value`, so don't use this for values that are supposed to be continuous.
     */
    public var integralizeValues: Bool = false

    /**
     A unique identifier that associates an animation with an grouped animation block.
     */
    var groupUUID: UUID?

    var startTime: TimeInterval?

    var relativePriority: Int = 0

    /**
     Creates a new animation with a given `Spring`, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - parameter spring: The spring model that determines the animation's motion.
     - parameter value: The initial, starting value of the animation.
     - parameter target: The target value of the animation.
     */
    public init(spring: Spring, value: T? = nil, target: T? = nil) {
        self.value = value
        self.target = target
        velocity = T.zero

        self.spring = spring
    }

    /**
     Starts the animation (if not already running) with an optional delay.

     - parameter delay: The amount of time (measured in seconds) to wait before starting the animation.
     */
    public func start(afterDelay delay: TimeInterval = 0) {
        precondition(value != nil, "Animation must have a non-nil `value` before starting.")
        precondition(target != nil, "Animation must have a non-nil `target` before starting.")
        precondition(delay >= 0, "`delay` must be greater or equal to zero.")

        let start = {
            AnimationController.shared.runPropertyAnimation(self)
        }
        
        delayTask?.cancel()

        if delay == .zero {
            start()
        } else {
            let task = DispatchWorkItem {
                start()
            }
            delayTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
        }
    }
    
    internal var delayTask: DispatchWorkItem? = nil

    /**
     Stops the animation at the current value.
     */
    public func stop(immediately: Bool = true) {
        delayTask?.cancel()
        if immediately {
            state = .ended

            if let value = value, let completion = completion {
                completion(.finished(at: value))
            }
        } else {
            target = value
        }
    }
    
    /// Stops the animation immediately at the specified target.
    public func stop(at target: T) {
        AnimationController.shared.stopPropertyAnimation(self)
        value = target
        self.target = value
        state = .inactive
        let callbackValue = integralizeValues ? target.scaledIntegral : target
        valueChanged?(callbackValue)
        if let completion = self.completion {
            completion(.finished(at: target))
        }
    }

    /**
     How long the animation will take to complete, based off its `spring` property.

     Note: This is useful for debugging purposes only. Do not use `settlingTime` to determine the animation's progress.
     */
    public var settlingTime: TimeInterval {
        spring.settlingDuration
    }

    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        spring = settings.spring
    }

    var runningTime: TimeInterval? {
        if let startTime = startTime {
            return (.now - startTime)
        } else {
            return nil
        }
    }

    func reset() {
        startTime = nil
        velocity = .zero
        state = .inactive
    }
    
    func updateAnimation(dt: TimeInterval) {
        guard var value = value, let target = target else {
            // Can't start an animation without a value and target
            state = .inactive
            return
        }

        state = .running

        guard let runningTime = runningTime else {
            fatalError("Found a nil `runningTime` even though the animation's state is \(state)")
        }


        let isAnimated = spring.response > .zero

        if isAnimated {
            spring.update(value: &value, velocity: &velocity, target: target, deltaTime: dt)
            self.value = value
        } else {
            self.value = target
            velocity = T.zero
        }

        let animationFinished = (runningTime >= settlingTime) || !isAnimated

        if animationFinished {
            self.value = target
        }

        if let value = self.value {
            let callbackValue = integralizeValues ? value.scaledIntegral : value
            valueChanged?(callbackValue)
        }

        if animationFinished {
            // If an animation finishes on its own, call the completion handler with value `target`.
            completion?(.finished(at: target))
            state = .ended
        }
    }
}

extension SpringAnimator: CustomStringConvertible {
    public var description: String {
        """
        Animation<\(T.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))

            state: \(state)

            value: \(String(describing: value))
            target: \(String(describing: target))
            velocity: \(String(describing: velocity))

            mode: \(spring.response > 0 ? "animated" : "nonAnimated")
            integralizeValues: \(integralizeValues)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

            priority: \(relativePriority)
        )
        """
    }
}






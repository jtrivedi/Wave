//
//  SpringAnimator.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import QuartzCore

public class SpringAnimator<T: SpringInterpolatable>: AnimatorProviding {

    public enum Event {
        /**
         Indicates the animation has fully completed.
         */
        case finished(at: T.ValueType)

        /**
         Indicates that the animation's `target` value was changed in-flight (i.e. while the animation was running).
         
         - parameter from: The previous `target` value of the animation.
         - parameter to: The new `target` value of the animation.
         */
        case retargeted(from: T.ValueType, to: T.ValueType)
    }

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
                self.startTime = CACurrentMediaTime()

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
    public var value: T.ValueType?

    /**
     The current target value of the animation.
     
     You may modify this value while the animation is in-flight to "retarget" to a new target value.
     */
    public var target: T.ValueType? {
        didSet {
            guard let oldValue = oldValue, let newValue = target else {
                return
            }

            if oldValue == newValue {
                return
            }

            if state == .running {
                self.startTime = CACurrentMediaTime()

                let event = Event.retargeted(from: oldValue, to: newValue)
                completion?(event)
            }
        }
    }

    /**
     The current velocity of the animation.
     
     If animating a view's `center` or `frame` with a gesture, you may want to set `velocity` to the gesture's final velocity on touch-up.
     */
    public var velocity: T.VelocityType

    /**
     The callback block to call when the animation's `value` changes as it executes. Use the `currentValue` to drive your application's animations.
     */
    public var valueChanged: ((_ currentValue: T.ValueType) -> Void)?

    /**
     The completion block to call when the animation either finishes, or "re-targets" to a new target value.
     */
    public var completion: ((_ event: Event) -> Void)?

    /**
     The animation's `mode`. If set to `.nonAnimated`, the animation will snap to the target value when run.
     */
    public var mode: AnimationMode = .animated

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

    /**
     Creates a new animation with a given `Spring`, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.
     
     - parameter spring: The spring model that determines the animation's motion.
     - parameter value: The initial, starting value of the animation.
     - parameter target: The target value of the animation.
     */
    public init(spring: Spring, value: T.ValueType? = nil, target: T.ValueType? = nil) {
        self.value = value
        self.target = target
        self.velocity = T.VelocityType.zero

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

        if delay == .zero {
            start()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                start()
            }
        }
    }

    /**
     Stops the animation at the current value.
     */
    public func stop(immediately: Bool = true) {
        if immediately {
            self.state = .ended

            if let value = value, let completion = completion {
                completion(.finished(at: value))
            }
        } else {
            self.target = self.value
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
        self.groupUUID = settings.groupUUID
        self.mode = settings.mode
        self.spring = settings.spring
    }

    var runningTime: TimeInterval? {
        if let startTime = startTime {
            return (CACurrentMediaTime() - startTime)
        } else {
            return nil
        }
    }

    func reset() {
        self.startTime = nil
        self.velocity = .zero
        self.state = .inactive
    }

    func updateAnimation(dt: TimeInterval) {
        guard let value = value, let target = target else {
            // Can't start an animation without a value and target
            self.state = .inactive
            return
        }

        self.state = .running

        guard let runningTime = runningTime else {
            fatalError("Found a nil `runningTime` even though the animation's state is \(state)")
        }

        let newValue: T.ValueType
        let newVelocity: T.VelocityType

        let isAnimated = spring.response > .zero && mode != .nonAnimated

        if isAnimated {
            (newValue, newVelocity) = T.updateValue(spring: spring, value: value, target: target, velocity: velocity, dt: dt)
        } else {
            newValue = target
            newVelocity = T.VelocityType.zero
        }

        self.value = newValue
        self.velocity = newVelocity

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
            self.state = .ended
        }
    }
}

extension SpringAnimator: CustomStringConvertible {
    public var description: String {
"""
SpringAnimator<\(T.self)>(
    uuid: \(id)
    groupUUID: \(String(describing: groupUUID))

    state: \(state)

    value: \(String(describing: value))
    target: \(String(describing: target))
    velocity: \(String(describing: velocity))

    mode: \(mode)
    integralizeValues: \(integralizeValues)

    callback: \(String(describing: valueChanged))
    completion: \(String(describing: completion))
)
"""
    }
}

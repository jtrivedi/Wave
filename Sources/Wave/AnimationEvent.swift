//
//  AnimationEvent.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

public enum AnimationEvent<T> {
    /**
     Indicates the animation has fully completed.
     */
    case finished(at: T)

    /**
     Indicates that the animation's `target` value was changed in-flight (i.e. while the animation was running).

     - parameter from: The previous `target` value of the animation.
     - parameter to: The new `target` value of the animation.
     */
    case retargeted(from: T, to: T)
}

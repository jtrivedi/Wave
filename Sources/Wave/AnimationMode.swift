//
//  AnimationMode.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

/**
 The mode that determines whether a block should be animated or not.
 
 The default mode is `animated`, but the `nonAnimated` mode should be used
 when you want to interrupt an existing animation and "snap" to some new values instead.
 
 For example, the example below animates a circle from left to right:
 
 ```
 Wave.animate(spring: spring, mode: .animated) {
    circle.animator.center = CGPoint(x: 500, y: 100)
 }
 ```
 
 Suppose while the animation is running, you decide that the circle should snap to its final position.
 Simply calling:
 ```
 circle.center = CGPoint(x: 500, y: 100)
 ```
 
 will set the `center` value, but `center` will be overridden in the next frame because the animator is still running.
 
 For this to snap to its final `center` value correctly, we need to use a `nonAnimated` mode:
 
 ```
 Wave.animate(spring: spring, mode: .nonAnimated) {
    circle.animator.center = CGPoint(x: 500, y: 100)
 }
 ```
 */
public enum AnimationMode {
    /**
     The default mode.
     */
    case animated

    /**
     The `nonAnimated` mode directly sets the `Animation`'s value to the given value without animation.
     
     See the `AnimationMode` overview comment for more information.
     */
    case nonAnimated
}

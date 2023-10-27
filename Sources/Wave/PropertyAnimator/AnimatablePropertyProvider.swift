//
//  AnimatablePropertyProvider.swift
//
//
//  Created by Florian Zand on 27.10.23.
//


import Foundation

/// An object that provides animatable properties that can be accessed via ``AnimatablePropertyProvider/animator``.
public protocol AnimatablePropertyProvider: AnyObject {
    associatedtype Provider: AnimatablePropertyProvider = Self
    
    var animator: PropertyAnimator<Provider> { get }
}

extension AnimatablePropertyProvider  {
    /**
     Provides animatable properties. To animate a property, change it's value in an ``Wave/animate(withSpring:delay:gestureVelocity:animations:completion:)`` animation block.
          
     Example usage:
     ```swift
     Wave.animate(withSpring: .smooth) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     
     myView.animator.alpha = 0.0 // Stops animating the property and changes it imminently.
     ```
     
     To get/set a property of the object that is not provided as `animator` property, use the properties keypath on `animator`. The property needs to confirm to ``AnimatableData``.
     
     ```swift
     Wave.animate(withSpring: .smooth) {
        myView.animator[\.myAnimatableProperty] = newValue
     }
     ```
     For easier access of the property, you can extend the object's PropertyAnimator.
     
     ```swift
     public extension PropertyAnimator<NSView> {
        var myAnimatableProperty: CGFloat {
            get { self[\.myAnimatableProperty] }
            set { self[\.myAnimatableProperty] = newValue }
        }
     }
     
     Wave.animate(withSpring: .smooth) {
        myView.animator.myAnimatableProperty = newValue
     }
     ```
     */
    public var animator: PropertyAnimator<Self> {
        get { getAssociatedValue(key: "Animator", object: self, initialValue: PropertyAnimator(self)) }
        set { set(associatedValue: newValue, key: "Animator", object: self) }
    }
}

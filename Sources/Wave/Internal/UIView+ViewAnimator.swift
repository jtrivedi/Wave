//
//  UIView+ViewAnimator.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import UIKit

private var ViewAnimatorAssociatedObjectHandle: UInt8 = 1 << 4
private var ViewAnimationsAssociatedObjectHandle: UInt8 = 1 << 5

extension UIView {

    /**
     Use the `animator` property to set any animatable properties on a `UIView` in an ``Wave.animateWith(...)`` animation block.
     
     Example usage:
     ```
     Wave.animateWith(spring: spring) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     ```
     
     See ``ViewAnimator`` for a list of supported animatable properties on `UIView`.
     */
    public var animator: ViewAnimator {
        get {
            if let viewAnimator = objc_getAssociatedObject(self, &ViewAnimatorAssociatedObjectHandle) as? ViewAnimator {
                return viewAnimator
            } else {
                self.animator = ViewAnimator(view: self)
                return self.animator
            }
        }
        set {
            objc_setAssociatedObject(self, &ViewAnimatorAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal var animators: [ViewAnimator.AnimatableProperty: AnimatorProviding] {
        get {
            objc_getAssociatedObject(self, &ViewAnimationsAssociatedObjectHandle) as? [ViewAnimator.AnimatableProperty: AnimatorProviding] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &ViewAnimationsAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

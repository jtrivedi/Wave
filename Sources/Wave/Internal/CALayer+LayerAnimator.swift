//
//  CALayer+LayerAnimator.swift
//  
//
//  Copyright (c) 2022 Janum Trivedi
//

import Foundation
import UIKit

private var LayerAnimatorAssociatedObjectHandle: UInt8 = 1 << 4
private var LayerAnimationsAssociatedObjectHandle: UInt8 = 1 << 5

extension CALayer {

    /**
     Use the `animator` property to set any animatable properties on a `CALayer` in an ``Wave.animateWith(...)`` animation block.

     Example usage:
     ```
     Wave.animateWith(spring: spring) {
     myView.layer.animator.shadowColor = UIColor.black.cgColor
     myView.layer.animator.shadowOpacity = 0.3
     }
     ```

     See ``LayerAnimator`` for a list of supported animatable properties on `UIView`.
     */
    public var animator: LayerAnimator {
        get {
            if let layerAnimator = objc_getAssociatedObject(self, &LayerAnimatorAssociatedObjectHandle) as? LayerAnimator {
                return layerAnimator
            } else {
                self.animator = LayerAnimator(layer: self)
                return self.animator
            }
        }
        set {
            objc_setAssociatedObject(self, &LayerAnimatorAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal var animators: [LayerAnimator.AnimatableProperty: AnimatorProviding] {
        get {
            objc_getAssociatedObject(self, &LayerAnimationsAssociatedObjectHandle) as? [LayerAnimator.AnimatableProperty: AnimatorProviding] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &LayerAnimationsAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

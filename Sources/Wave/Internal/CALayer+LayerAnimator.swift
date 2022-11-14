//
//  CALayer+LayerAnimator.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi
//

import Foundation

import QuartzCore
import CoreGraphics

private var LayerAnimatorAssociatedObjectHandle: UInt8 = 1 << 4
private var LayerAnimationsAssociatedObjectHandle: UInt8 = 1 << 5

extension CALayer {

    var _animator: LayerAnimator {
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

    var animators: [LayerAnimator.AnimatableProperty: AnimatorProviding] {
        get {
            objc_getAssociatedObject(self, &LayerAnimationsAssociatedObjectHandle) as? [LayerAnimator.AnimatableProperty: AnimatorProviding] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &LayerAnimationsAssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

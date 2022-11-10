//
//  UIViewAnimatableProperties.swift
//  
//
//  Copyright (c) 2022 Janum Trivedi.
//

import UIKit

/**
 The `ViewAnimator` class contains the supported UIView animatable properties, like `frame`, `center`, `backgroundColor`, and more.

 In an Wave animation block, change these values to create an animation, like so:

 Example usage:
 ```
 Wave.animateWith(spring: .defaultAnimated) {
    myView.animator.center = CGPoint(x: 100, y: 100)
    myView.animator.alpha = 0.5
 }
 ```
 */
public class ViewAnimator {

    // MARK: - Public

    /// The bounds of the attached `UIView`.
    public var bounds: CGRect {
        get { _bounds }
        set { _bounds = newValue }
    }

    /// The frame of the attached `UIView`.
    public var frame: CGRect {
        get { _frame }
        set { _frame = newValue }
    }

    /// The origin of the attached `UIView`.
    public var origin: CGPoint {
        get { _origin }
        set { _origin = newValue }
    }

    /// The center of the attached `UIView`.
    public var center: CGPoint {
        get { _center }
        set { _center = newValue }
    }

    /// The background color of the attached `UIView`.
    public var backgroundColor: UIColor {
        get { _backgroundColor }
        set { _backgroundColor = newValue }
    }

    /// The alpha of the attached `UIView`.
    public var alpha: CGFloat {
        get { _alpha }
        set { _alpha = newValue }
    }

    /// The corner radius of the attached `UIView`'s `layer`.
    /// This is a convenience API that forwards to the `CALayer`'s `animator`.
    public var cornerRadius: CGFloat {
        get { _cornerRadius }
        set { _cornerRadius = newValue }
    }

    /// The border color of the attached `UIView`'s `layer`.
    /// This is a convenience API that forwards to the `CALayer`'s `animator`.
    public var borderColor: UIColor {
        get { _borderColor }
        set { _borderColor = newValue }
    }

    /// The border width of the attached `UIView`'s `layer`.
    /// This is a convenience API that forwards to the `CALayer`'s `animator`.
    public var borderWidth: CGFloat {
        get { _borderWidth }
        set { _borderWidth = newValue }
    }

    /// The shadow color of the attached `UIView`'s `layer'.`
    /// This is a convenience API that forwards to the `CALayer`'s `animator`.
    public var shadowColor: UIColor {
        get { _shadowColor }
        set { _shadowColor = newValue }
    }

    /// The shadow opacity of the attached `UIView`'s `layer'.`
    /// This is a convenience API that forwards to the `CALayer`'s `animator`.
    public var shadowOpacity: CGFloat {
        get { _shadowOpacity }
        set { _shadowOpacity = newValue }
    }

    /// The shadow offset of the attached `UIView`'s `layer'.`
    /// This is a convenience API that forwards to the `CALayer`'s `animator`.
    public var shadowOffset: CGSize {
        get { _shadowOffset }
        set { _shadowOffset = newValue }
    }

    /// The shadow radius of the attached `UIView`'s `layer'.`
    /// This is a convenience API that forwards to the `CALayer`'s `animator`.
    public var shadowRadius: CGFloat {
        get { _shadowRadius }
        set { _shadowRadius = newValue }
    }

    /// The affine scale transform of the attached `UIView`'s `layer`.
    public var scale: CGPoint {
        get { _scale }
        set { _scale = newValue }
    }

    /// The affine translation transform of the attached `UIView`'s `layer`.
    public var translation: CGPoint {
        get { _translation }
        set { _translation = newValue }
    }

    // MARK: - Internal

    let view: UIView

    init(view: UIView) {
        self.view = view
    }

}

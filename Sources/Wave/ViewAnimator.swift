//
//  ViewAnimator.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

/**
 The `ViewAnimator` class contains the supported UIView animatable properties, like `frame`, `center`, `cornerRadius`, and more.
 
 In an Wave animation block, change these values to create an animation, like so:
 
 Example usage:
 ```
 Wave.animateWith(spring: spring) {
 myView.animator.center = CGPoint(x: 100, y: 100)
 myView.animator.alpha = 0.5
 }
 ```
 */
public class ViewAnimator {

    internal enum AnimatableProperty: Int {
        case frameCenter
        case frameOrigin

        case boundsSize
        case boundsOrigin

        case alpha
        case backgroundColor

        case scale
        case translation
        case cornerRadius

        case shadowOpacity
        case shadowOffset
        case shadowRadius
    }

    var view: UIView

    init(view: UIView) {
        self.view = view
    }

    // MARK: - Public

    /// The bounds of the attached `UIView`.
    public var bounds: CGRect {
        get {
            CGRect(origin: view.animator.boundsOrigin, size: view.animator.boundsSize)
        }
        set {
            guard bounds != newValue else {
                return
            }

            // `bounds.size`
            self.boundsSize = newValue.size

            // `bounds.origin`
            self.boundsOrigin = newValue.origin
        }
    }

    /// The frame of the attached `UIView`.
    public var frame: CGRect {
        get {
            CGRect(aroundPoint: view.animator.center, size: view.animator.boundsSize)
        }
        set {
            guard frame != newValue else {
                return
            }

            // `bounds.size`
            self.boundsSize = newValue.size

            // `frame.center`
            self.center = newValue.center
        }
    }

    /// The origin of the attached `UIView`.
    public var origin: CGPoint {
        get {
            view.animator.frame.origin
        }
        set {
            guard origin != newValue else {
                return
            }

            // `frame.center`
            self.center = CGPoint(x: newValue.x + bounds.width / 2.0, y: newValue.y + bounds.height / 2.0)
        }
    }

    /// The center of the attached `UIView`.
    public var center: CGPoint {
        get {
            runningCenterAnimator?.target ?? view.center
        }
        set {
            guard center != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.center = newValue
                }
                return
            }

            let initialValue = view.center
            let targetValue = newValue

            let animationType = AnimatableProperty.frameCenter

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningCenterAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningCenterAnimator ?? Animation<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            if let gestureVelocity = settings.gestureVelocity {
                animation.velocity = gestureVelocity
            }

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.center = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    private var boundsOrigin: CGPoint {
        get {
            runningBoundsOriginAnimator?.target ?? view.bounds.origin
        }
        set {
            guard boundsOrigin != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.bounds.origin = newValue
                }
                return
            }

            let initialValue = view.bounds.origin
            let targetValue = newValue

            let animationType = AnimatableProperty.boundsOrigin

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBoundsOriginAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningBoundsOriginAnimator ?? Animation<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] boundsOrigin in
                self?.view.bounds.origin = boundsOrigin
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    private var boundsSize: CGSize {
        get {
            runningBoundsSizeAnimator?.target ?? view.bounds.size
        }
        set {
            guard boundsSize != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.bounds.size = newValue
                }
                return
            }

            let initialValue = view.bounds.size
            let targetValue = newValue

            let animationType = AnimatableProperty.boundsSize

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBoundsSizeAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningBoundsSizeAnimator ?? Animation<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] size in
                guard let strongSelf = self else { return }
                strongSelf.view.bounds = CGRect(origin: strongSelf.view.bounds.origin, size: size)
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The background color of the attached `UIView`.
    public var backgroundColor: UIColor? {
        get {
            view.backgroundColor
        }
        set {
            guard backgroundColor != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.backgroundColor = newValue
                }
                return
            }

            guard let targetValue = newValue else {
                view.backgroundColor = nil
                return
            }

            let animationType = AnimatableProperty.backgroundColor
            let existingAnimationForType = view.animations[animationType]

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: existingAnimationForType?.groupUUID, finished: false, retargeted: true)

            let animation = (existingAnimationForType as? Animation<CGFloat> ?? Animation<CGFloat>(spring: settings.spring, value: 0, target: 1))

            animation.configure(withSettings: settings)

            let initialColor = view.backgroundColor

            animation.valueChanged = { [weak self] progress in
                if let initialColor = initialColor {
                    self?.view.backgroundColor = UIColor.interpolate(from: initialColor, to: targetValue, with: progress)
                }
            }

            animation.value = 0
            animation.target = 1.0
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }


    /// The alpha of the attached `UIView`.
    public var alpha: CGFloat {
        get {
            runningAlphaAnimator?.target ?? view.alpha
        }
        set {
            guard alpha != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.alpha = newValue
                }
                return
            }

            let initialValue = view.alpha
            let targetValue = newValue

            let animationType = AnimatableProperty.alpha

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningAlphaAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningAlphaAnimator ?? Animation<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.alpha = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The scale transform of the attached `UIView`'s `layer`.
    public var scale: CGPoint {
        get {
            let currentScale = CGPoint(x: view.transform.a, y: view.transform.d)
            return runningScaleAnimator?.target ?? currentScale
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.scale = newValue
                }
                return
            }

            let initialValue = CGPoint(x: view.transform.a, y: view.transform.d)
            let targetValue = newValue

            let animationType = AnimatableProperty.scale

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningScaleAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningScaleAnimator ?? Animation<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }

                var transform = strongSelf.view.transform
                transform.a = max(value.x, 0.0) // [1, 1]
                transform.d = max(value.y, 0.0) // [2, 2]
                strongSelf.view.transform = transform
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The translation transform of the attached `UIView`'s `layer`.
    public var translation: CGPoint {
        get {
            let currentTranslation = CGPoint(x: view.transform.tx, y: view.transform.ty)
            return runningTranslationAnimator?.target ?? currentTranslation
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.translation = newValue
                }
                return
            }

            guard translation != newValue else {
                return
            }

            let initialValue = CGPoint(x: view.transform.tx, y: view.transform.ty)
            let targetValue = newValue

            let animationType = AnimatableProperty.translation

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningTranslationAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningTranslationAnimator ?? Animation<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }

                var transform = strongSelf.view.transform
                transform.tx = value.x
                transform.ty = value.y
                strongSelf.view.transform = transform
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The corner radius of the attached `UIView`'s `layer`.
    public var cornerRadius: CGFloat {
        get {
            runningCornerRadiusAnimator?.target ?? view.layer.cornerRadius
        }
        set {
            guard cornerRadius != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.cornerRadius = newValue
                }
                return
            }

            let initialValue = view.layer.cornerRadius
            let targetValue = newValue

            let animationType = AnimatableProperty.cornerRadius

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningCornerRadiusAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningCornerRadiusAnimator ?? Animation<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.layer.cornerRadius = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

}

extension ViewAnimator {

    /// The shadow opacity of the attached `UIView`'s layer.
    public var shadowOpacity: CGFloat {
        get {
            runningShadowOpacityAnimator?.target ?? CGFloat(view.layer.shadowOpacity)
        }
        set {
            guard shadowOpacity != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowOpacity = newValue
                }
                return
            }

            let initialValue = CGFloat(view.layer.shadowOpacity)
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOpacity

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowOpacityAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowOpacityAnimator ?? Animation<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                let clippedValue = Float(clipUnit(value: value))
                self?.view.layer.shadowOpacity = clippedValue
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The shadow offset of the attached `UIView`'s layer.
    public var shadowOffset: CGSize {
        get {
            runningShadowOffsetAnimator?.target ?? view.layer.shadowOffset
        }
        set {
            guard shadowOffset != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowOffset = newValue
                }
                return
            }

            let initialValue = view.layer.shadowOffset
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOffset

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowOffsetAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowOffsetAnimator ?? Animation<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.layer.shadowOffset = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The shadow radius of the attached `UIView`'s layer.
    public var shadowRadius: CGFloat {
        get {
            runningShadowRadiusAnimator?.target ?? CGFloat(view.layer.shadowRadius)
        }
        set {
            guard shadowRadius != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowRadius = newValue
                }
                return
            }

            let initialValue = CGFloat(view.layer.shadowRadius)
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowRadius

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowRadiusAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowRadiusAnimator ?? Animation<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.layer.shadowRadius = max(0, value)
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animations.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }
}

extension ViewAnimator {

    // MARK: - Internal

    private func start(animation: AnimationProviding, type: AnimatableProperty, delay: TimeInterval) {
        view.animations[type] = animation
        animation.start(afterDelay: delay)
    }

    private var runningCenterAnimator: Animation<CGPoint>? {
        view.animations[AnimatableProperty.frameCenter] as? Animation<CGPoint>
    }

    private var runningBoundsOriginAnimator: Animation<CGPoint>? {
        view.animations[AnimatableProperty.boundsOrigin] as? Animation<CGPoint>
    }

    private var runningBoundsSizeAnimator: Animation<CGSize>? {
        view.animations[AnimatableProperty.boundsSize] as? Animation<CGSize>
    }

    private var runningScaleAnimator: Animation<CGPoint>? {
        view.animations[AnimatableProperty.scale] as? Animation<CGPoint>
    }

    private var runningTranslationAnimator: Animation<CGPoint>? {
        view.animations[AnimatableProperty.translation] as? Animation<CGPoint>
    }

    private var runningAlphaAnimator: Animation<CGFloat>? {
        view.animations[AnimatableProperty.alpha] as? Animation<CGFloat>
    }

    private var runningCornerRadiusAnimator: Animation<CGFloat>? {
        view.animations[AnimatableProperty.cornerRadius] as? Animation<CGFloat>
    }

    private var runningShadowOpacityAnimator: Animation<CGFloat>? {
        view.animations[AnimatableProperty.shadowOpacity] as? Animation<CGFloat>
    }

    private var runningShadowOffsetAnimator: Animation<CGSize>? {
        view.animations[AnimatableProperty.shadowOffset] as? Animation<CGSize>
    }

    private var runningShadowRadiusAnimator: Animation<CGFloat>? {
        view.animations[AnimatableProperty.shadowRadius] as? Animation<CGFloat>
    }
}

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

        case backgroundColor
        case alpha

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

            let animation = (runningCenterAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

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
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningBoundsOriginAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] boundsOrigin in
                self?.view.bounds.origin = boundsOrigin
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningBoundsSizeAnimator ?? SpringAnimator<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] size in
                guard let strongSelf = self else { return }
                strongSelf.view.bounds = CGRect(origin: strongSelf.view.bounds.origin, size: size)
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The background color of the attached `UIView`.
    public var backgroundColor: UIColor {
        get {
            if let targetComponents = runningBackgroundColorAnimator?.target {
                return targetComponents.uiColor
            } else {
                return view.backgroundColor ?? .clear
            }
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

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero.
            let initialValue = view.backgroundColor ?? .clear

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue = (newValue == UIColor.clear) ? backgroundColor.withAlphaComponent(0) : newValue

            let animationType = AnimatableProperty.backgroundColor

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBackgroundColorAnimator?.groupUUID, finished: false, retargeted: true)

            let initialValueComponents = RGBAComponents(color: initialValue)
            let targetValueComponents = RGBAComponents(color: targetValue)

            let animation = (runningBackgroundColorAnimator ??
                             SpringAnimator<RGBAComponents>(
                                spring: settings.spring,
                                value:  initialValueComponents,
                                target: targetValueComponents
                             )
            )

            animation.configure(withSettings: settings)

            animation.target = targetValueComponents
            animation.valueChanged = { [weak self] components in
                self?.view.backgroundColor = components.uiColor
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningAlphaAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.alpha = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningScaleAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

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
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningTranslationAnimator ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))

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
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningCornerRadiusAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.layer.cornerRadius = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningShadowOpacityAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                let clippedValue = Float(clipUnit(value: value))
                self?.view.layer.shadowOpacity = clippedValue
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningShadowOffsetAnimator ?? SpringAnimator<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.layer.shadowOffset = value
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
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

            let animation = (runningShadowRadiusAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.layer.shadowRadius = max(0, value)
            }

            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
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

    private func start(animation: AnimatorProviding, type: AnimatableProperty, delay: TimeInterval) {
        view.animators[type] = animation
        animation.start(afterDelay: delay)
    }

    private var runningCenterAnimator: SpringAnimator<CGPoint>? {
        view.animators[AnimatableProperty.frameCenter] as? SpringAnimator<CGPoint>
    }

    private var runningBoundsOriginAnimator: SpringAnimator<CGPoint>? {
        view.animators[AnimatableProperty.boundsOrigin] as? SpringAnimator<CGPoint>
    }

    private var runningBoundsSizeAnimator: SpringAnimator<CGSize>? {
        view.animators[AnimatableProperty.boundsSize] as? SpringAnimator<CGSize>
    }

    private var runningScaleAnimator: SpringAnimator<CGPoint>? {
        view.animators[AnimatableProperty.scale] as? SpringAnimator<CGPoint>
    }

    private var runningTranslationAnimator: SpringAnimator<CGPoint>? {
        view.animators[AnimatableProperty.translation] as? SpringAnimator<CGPoint>
    }

    private var runningBackgroundColorAnimator: SpringAnimator<RGBAComponents>? {
        view.animators[AnimatableProperty.backgroundColor] as? SpringAnimator<RGBAComponents>
    }

    private var runningAlphaAnimator: SpringAnimator<CGFloat>? {
        view.animators[AnimatableProperty.alpha] as? SpringAnimator<CGFloat>
    }

    private var runningCornerRadiusAnimator: SpringAnimator<CGFloat>? {
        view.animators[AnimatableProperty.cornerRadius] as? SpringAnimator<CGFloat>
    }

    private var runningShadowOpacityAnimator: SpringAnimator<CGFloat>? {
        view.animators[AnimatableProperty.shadowOpacity] as? SpringAnimator<CGFloat>
    }

    private var runningShadowOffsetAnimator: SpringAnimator<CGSize>? {
        view.animators[AnimatableProperty.shadowOffset] as? SpringAnimator<CGSize>
    }

    private var runningShadowRadiusAnimator: SpringAnimator<CGFloat>? {
        view.animators[AnimatableProperty.shadowRadius] as? SpringAnimator<CGFloat>
    }
}

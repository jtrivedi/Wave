//
//  ViewAnimator+Implementation.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import CoreGraphics
import QuartzCore

#if os(iOS)
import UIKit

extension ViewAnimator {

    internal enum AnimatableProperty: Int {
        case frameCenter
        case frameOrigin

        case boundsSize
        case boundsOrigin

        case backgroundColor
        case alpha

        case scale
        case translation
    }

    var _bounds: CGRect {
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

    var _frame: CGRect {
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

    var _origin: CGPoint {
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

    var _center: CGPoint {
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

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var boundsOrigin: CGPoint {
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

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var boundsSize: CGSize {
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

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _backgroundColor: UIColor {
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
                                value: initialValueComponents,
                                target: targetValueComponents
                             )
            )

            animation.configure(withSettings: settings)

            animation.target = targetValueComponents
            animation.valueChanged = { [weak self] components in
                self?.view.backgroundColor = components.uiColor
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _alpha: CGFloat {
        get {
            view.layer.animator.opacity
        }
        set {
            view.layer.animator.opacity = newValue
        }
    }

    var _cornerRadius: CGFloat {
        get {
            view.layer.animator.cornerRadius
        }
        set {
            view.layer.animator.cornerRadius = newValue
        }
    }

    var _borderColor: UIColor {
        get {
            UIColor(cgColor: view.layer.animator.borderColor)
        }
        set {
            view.layer.animator.borderColor = newValue.cgColor
        }
    }

    var _borderWidth: CGFloat {
        get {
            view.layer.animator.borderWidth
        }
        set {
            view.layer.animator.borderWidth = newValue
        }
    }

    var _shadowColor: UIColor {
        get {
            UIColor(cgColor: view.layer.animator.shadowColor)
        }
        set {
            view.layer.animator.shadowColor = newValue.cgColor
        }
    }

    var _shadowOpacity: CGFloat {
        get {
            view.layer.animator.shadowOpacity
        }
        set {
            view.layer.animator.shadowOpacity = newValue
        }
    }

    var _shadowOffset: CGSize {
        get {
            view.layer.animator.shadowOffset
        }
        set {
            view.layer.animator.shadowOffset = newValue
        }
    }

    var _shadowRadius: CGFloat {
        get {
            view.layer.animator.shadowRadius
        }
        set {
            view.layer.animator.shadowRadius = newValue
        }
    }

    var _scale: CGPoint {
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
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }

                var transform = strongSelf.view.transform
                transform.a = max(value.x, 0.0) // [1, 1]
                transform.d = max(value.y, 0.0) // [2, 2]
                strongSelf.view.transform = transform
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _translation: CGPoint {
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
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }

                var transform = strongSelf.view.transform
                transform.tx = value.x
                transform.ty = value.y
                strongSelf.view.transform = transform
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
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

}

#endif

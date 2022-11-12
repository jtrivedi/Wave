//
//  LayerAnimator.swift
//  
//
//  Copyright (c) 2022 Janum Trivedi
//

import Foundation
import UIKit

extension LayerAnimator {

    internal enum AnimatableProperty: Int {
        case cornerRadius
        case opacity

        case borderColor
        case borderWidth

        case shadowColor
        case shadowOpacity
        case shadowOffset
        case shadowRadius
    }

    var _cornerRadius: CGFloat {
        get {
            runningCornerRadiusAnimator?.target ?? layer.cornerRadius
        }
        set {
            guard cornerRadius != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.cornerRadius = newValue
                }
                return
            }

            let initialValue = layer.cornerRadius
            let targetValue = newValue

            let animationType = AnimatableProperty.cornerRadius

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningCornerRadiusAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningCornerRadiusAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.layer.cornerRadius = value
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _opacity: CGFloat {
        get {
            runningOpacityAnimator?.target ?? CGFloat(layer.opacity)
        }
        set {
            guard opacity != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.opacity = newValue
                }
                return
            }

            let initialValue = CGFloat(layer.opacity)
            let targetValue = newValue

            let animationType = AnimatableProperty.opacity

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningOpacityAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningOpacityAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.layer.opacity = Float(clipUnit(value: value))
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _borderColor: CGColor {
        get {
            if let targetComponents = runningBorderColorAnimator?.target {
                return targetComponents.uiColor.cgColor
            } else {
                return layer.borderColor ?? UIColor.black.cgColor
            }
        }

        set {
            guard borderColor != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.borderColor = newValue
                }
                return
            }

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero
            let initialValue: UIColor
            if let borderColor = layer.borderColor {
                initialValue = UIColor(cgColor: borderColor)
            } else {
                initialValue = UIColor.black
            }

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue: UIColor
            if UIColor(cgColor: newValue) == .clear {
                targetValue = UIColor(cgColor: borderColor).withAlphaComponent(0)
            } else {
                targetValue = UIColor(cgColor: newValue)
            }

            let animationType = AnimatableProperty.borderColor

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBorderColorAnimator?.groupUUID, finished: false, retargeted: true)

            let initialValueComponents = RGBAComponents(color: initialValue)
            let targetValueComponents = RGBAComponents(color: targetValue)

            let animation = (runningBorderColorAnimator ??
                             SpringAnimator<RGBAComponents>(
                                spring: settings.spring,
                                value: initialValueComponents,
                                target: targetValueComponents
                             )
            )

            animation.configure(withSettings: settings)

            animation.target = targetValueComponents
            animation.valueChanged = { [weak self] components in
                self?.layer.borderColor = components.uiColor.cgColor
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _borderWidth: CGFloat {
        get {
            runningBorderWidthAnimator?.target ?? layer.borderWidth
        }
        set {
            guard borderWidth != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.borderWidth = newValue
                }
                return
            }

            let initialValue = layer.borderWidth
            let targetValue = newValue

            let animationType = AnimatableProperty.borderWidth

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningBorderWidthAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningBorderWidthAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))

            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.layer.borderWidth = value
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _shadowOpacity: CGFloat {
        get {
            runningShadowOpacityAnimator?.target ?? CGFloat(layer.shadowOpacity)
        }
        set {
            guard shadowOpacity != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.shadowOpacity = newValue
                }
                return
            }

            let initialValue = CGFloat(layer.shadowOpacity)
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOpacity

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowOpacityAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowOpacityAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                let clippedValue = Float(clipUnit(value: value))
                self?.layer.shadowOpacity = clippedValue
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _shadowColor: CGColor {
        get {
            if let targetComponents = runningShadowColorAnimator?.target {
                return targetComponents.uiColor.cgColor
            } else {
                return layer.backgroundColor ?? UIColor.clear.cgColor
            }
        }

        set {
            guard shadowColor != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.shadowColor = newValue
                }
                return
            }

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero
            let initialValue: UIColor
            if let shadowColor = layer.shadowColor {
                initialValue = UIColor(cgColor: shadowColor)
            } else {
                initialValue = UIColor.clear
            }

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue: UIColor
            if UIColor(cgColor: newValue) == .clear {
                targetValue = UIColor(cgColor: shadowColor).withAlphaComponent(0)
            } else {
                targetValue = UIColor(cgColor: newValue)
            }

            let animationType = AnimatableProperty.shadowColor

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowColorAnimator?.groupUUID, finished: false, retargeted: true)

            let initialValueComponents = RGBAComponents(color: initialValue)
            let targetValueComponents = RGBAComponents(color: targetValue)

            let animation = (runningShadowColorAnimator ??
                             SpringAnimator<RGBAComponents>(
                                spring: settings.spring,
                                value: initialValueComponents,
                                target: targetValueComponents
                             )
            )

            animation.configure(withSettings: settings)

            animation.target = targetValueComponents
            animation.valueChanged = { [weak self] components in
                self?.layer.shadowColor = components.uiColor.cgColor
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    /// The shadow offset of the attached layer.
    var _shadowOffset: CGSize {
        get {
            runningShadowOffsetAnimator?.target ?? layer.shadowOffset
        }
        set {
            guard shadowOffset != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.shadowOffset = newValue
                }
                return
            }

            let initialValue = layer.shadowOffset
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOffset

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowOffsetAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowOffsetAnimator ?? SpringAnimator<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.layer.shadowOffset = value
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

    var _shadowRadius: CGFloat {
        get {
            runningShadowRadiusAnimator?.target ?? CGFloat(layer.shadowRadius)
        }
        set {
            guard shadowRadius != newValue else {
                return
            }

            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .defaultNonAnimated, mode: .nonAnimated) {
                    self.layer.animator.shadowRadius = newValue
                }
                return
            }

            let initialValue = CGFloat(layer.shadowRadius)
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowRadius

            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: runningShadowRadiusAnimator?.groupUUID, finished: false, retargeted: true)

            let animation = (runningShadowRadiusAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)

            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.layer.shadowRadius = max(0, value)
            }

            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.layer.animators.removeValue(forKey: animationType)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }

            start(animation: animation, type: animationType, delay: settings.delay)
        }
    }

}

extension LayerAnimator {

    // MARK: - Internal

    private func start(animation: AnimatorProviding, type: AnimatableProperty, delay: TimeInterval) {
        layer.animators[type] = animation
        animation.start(afterDelay: delay)
    }

    private var runningCornerRadiusAnimator: SpringAnimator<CGFloat>? {
        layer.animators[AnimatableProperty.cornerRadius] as? SpringAnimator<CGFloat>
    }

    private var runningOpacityAnimator: SpringAnimator<CGFloat>? {
        layer.animators[AnimatableProperty.opacity] as? SpringAnimator<CGFloat>
    }

    private var runningBorderColorAnimator: SpringAnimator<RGBAComponents>? {
        layer.animators[AnimatableProperty.borderColor] as? SpringAnimator<RGBAComponents>
    }

    private var runningBorderWidthAnimator: SpringAnimator<CGFloat>? {
        layer.animators[AnimatableProperty.borderWidth] as? SpringAnimator<CGFloat>
    }

    private var runningShadowColorAnimator: SpringAnimator<RGBAComponents>? {
        layer.animators[AnimatableProperty.shadowColor] as? SpringAnimator<RGBAComponents>
    }

    private var runningShadowOpacityAnimator: SpringAnimator<CGFloat>? {
        layer.animators[AnimatableProperty.shadowOpacity] as? SpringAnimator<CGFloat>
    }

    private var runningShadowOffsetAnimator: SpringAnimator<CGSize>? {
        layer.animators[AnimatableProperty.shadowOffset] as? SpringAnimator<CGSize>
    }

    private var runningShadowRadiusAnimator: SpringAnimator<CGFloat>? {
        layer.animators[AnimatableProperty.shadowRadius] as? SpringAnimator<CGFloat>
    }
}

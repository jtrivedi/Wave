//
//  LayerAnimator+Implementation.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi
//

import Foundation
import CoreGraphics
import QuartzCore

extension LayerAnimator {

    internal enum AnimatableProperty: Int {
        case cornerRadius
        case opacity
        case backgroundColor

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

            let settings = resolvedAnimationSettings

            let initialValue = layer.cornerRadius
            let targetValue = newValue

            let animationType = AnimatableProperty.cornerRadius

            if applyImmediateValueIfPossible(existingAnimator: runningCornerRadiusAnimator, settings: settings, updates: {
                self.layer.cornerRadius = targetValue
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
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

            let settings = resolvedAnimationSettings

            let initialValue = CGFloat(layer.opacity)
            let targetValue = newValue

            let animationType = AnimatableProperty.opacity

            if applyImmediateValueIfPossible(existingAnimator: runningOpacityAnimator, settings: settings, updates: {
                self.layer.opacity = Float(clipUnit(value: targetValue))
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
        }
    }

    var _backgroundColor: CGColor {
        get {
            if let targetComponents = runningBackgroundColorAnimator?.target {
                return targetComponents.uiColor.cgColor
            } else {
                return layer.backgroundColor ?? WaveColor.clear.cgColor
            }
        }

        set {
            guard backgroundColor != newValue else {
                return
            }

            let settings = resolvedAnimationSettings

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero
            let initialValue: WaveColor
            if let backgroundColor = layer.backgroundColor {
                initialValue = WaveColor(_cgColor: backgroundColor)
            } else {
                initialValue = WaveColor.clear
            }

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue: WaveColor
            if WaveColor(cgColor: newValue) == .clear {
                targetValue = WaveColor(_cgColor: backgroundColor).withAlphaComponent(0)
            } else {
                targetValue = WaveColor(_cgColor: newValue)
            }

            let animationType = AnimatableProperty.backgroundColor

            if applyImmediateValueIfPossible(existingAnimator: runningBackgroundColorAnimator, settings: settings, updates: {
                self.layer.backgroundColor = targetValue.cgColor
            }) {
                return
            }

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
                self?.layer.backgroundColor = components.uiColor.cgColor
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

            start(animation: animation, type: animationType)
        }
    }

    var _borderColor: CGColor {
        get {
            if let targetComponents = runningBorderColorAnimator?.target {
                return targetComponents.uiColor.cgColor
            } else {
                return layer.borderColor ?? WaveColor.black.cgColor
            }
        }

        set {
            guard borderColor != newValue else {
                return
            }

            let settings = resolvedAnimationSettings

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero
            let initialValue: WaveColor
            if let borderColor = layer.borderColor {
                initialValue = WaveColor(_cgColor: borderColor)
            } else {
                initialValue = WaveColor.black
            }

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue: WaveColor
            if WaveColor(cgColor: newValue) == .clear {
                targetValue = WaveColor(_cgColor: borderColor).withAlphaComponent(0)
            } else {
                targetValue = WaveColor(_cgColor: newValue)
            }

            let animationType = AnimatableProperty.borderColor

            if applyImmediateValueIfPossible(existingAnimator: runningBorderColorAnimator, settings: settings, updates: {
                self.layer.borderColor = targetValue.cgColor
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
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

            let settings = resolvedAnimationSettings

            let initialValue = layer.borderWidth
            let targetValue = newValue

            let animationType = AnimatableProperty.borderWidth

            if applyImmediateValueIfPossible(existingAnimator: runningBorderWidthAnimator, settings: settings, updates: {
                self.layer.borderWidth = targetValue
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
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

            let settings = resolvedAnimationSettings

            let initialValue = CGFloat(layer.shadowOpacity)
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOpacity

            if applyImmediateValueIfPossible(existingAnimator: runningShadowOpacityAnimator, settings: settings, updates: {
                self.layer.shadowOpacity = Float(clipUnit(value: targetValue))
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
        }
    }

    var _shadowColor: CGColor {
        get {
            if let targetComponents = runningShadowColorAnimator?.target {
                return targetComponents.uiColor.cgColor
            } else {
                return layer.shadowColor ?? WaveColor.clear.cgColor
            }
        }

        set {
            guard shadowColor != newValue else {
                return
            }

            let settings = resolvedAnimationSettings

            // `nil` and `.clear` are the same -- they both are represented by `.white` with an alpha of zero
            let initialValue: WaveColor
            if let shadowColor = layer.shadowColor {
                initialValue = WaveColor(_cgColor: shadowColor)
            } else {
                initialValue = WaveColor.clear
            }

            // Animating to `clear` or `nil` really just animates the alpha component down to zero. Retain the other color components.
            let targetValue: WaveColor
            if WaveColor(cgColor: newValue) == .clear {
                targetValue = WaveColor(_cgColor: shadowColor).withAlphaComponent(0)
            } else {
                targetValue = WaveColor(_cgColor: newValue)
            }

            let animationType = AnimatableProperty.shadowColor

            if applyImmediateValueIfPossible(existingAnimator: runningShadowColorAnimator, settings: settings, updates: {
                self.layer.shadowColor = targetValue.cgColor
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
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

            let settings = resolvedAnimationSettings

            let initialValue = layer.shadowOffset
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowOffset

            if applyImmediateValueIfPossible(existingAnimator: runningShadowOffsetAnimator, settings: settings, updates: {
                self.layer.shadowOffset = targetValue
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
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

            let settings = resolvedAnimationSettings

            let initialValue = CGFloat(layer.shadowRadius)
            let targetValue = newValue

            let animationType = AnimatableProperty.shadowRadius

            if applyImmediateValueIfPossible(existingAnimator: runningShadowRadiusAnimator, settings: settings, updates: {
                self.layer.shadowRadius = max(0, targetValue)
            }) {
                return
            }

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

            start(animation: animation, type: animationType)
        }
    }

}

extension LayerAnimator {

    // MARK: - Internal

    private var resolvedAnimationSettings: AnimationController.AnimationParameters {
        AnimationController.shared.currentAnimationParametersOrImplicitNonAnimated()
    }

    private func applyImmediateValueIfPossible(
        existingAnimator: AnimatorProviding?,
        settings: AnimationController.AnimationParameters,
        updates: () -> Void
    ) -> Bool {
        guard settings.mode == .nonAnimated, existingAnimator == nil else {
            return false
        }

        AnimationController.shared.performImmediatePropertyChange(groupUUID: settings.groupUUID, updates: updates)
        return true
    }

    private func start(animation: AnimatorProviding, type: AnimatableProperty) {
        layer.animators[type] = animation
        animation.start()
    }

    private var runningCornerRadiusAnimator: SpringAnimator<CGFloat>? {
        layer.animators[AnimatableProperty.cornerRadius] as? SpringAnimator<CGFloat>
    }

    private var runningOpacityAnimator: SpringAnimator<CGFloat>? {
        layer.animators[AnimatableProperty.opacity] as? SpringAnimator<CGFloat>
    }

    private var runningBackgroundColorAnimator: SpringAnimator<RGBAComponents>? {
        layer.animators[AnimatableProperty.backgroundColor] as? SpringAnimator<RGBAComponents>
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

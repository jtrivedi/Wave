//
//  PropertyAnimator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

import Foundation
import QuartzCore

/// Provides animatable properties of an object conforming to `AnimatablePropertyProvider`.
public class PropertyAnimator<Object: AnimatablePropertyProvider> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }
    
    internal var animations: [String: AnimatorProviding] {
        get { getAssociatedValue(key: "animations", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "animations", object: self) }
    }
}

public extension PropertyAnimator {
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value>) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }
    
    subscript<Value: AnimatableData>(keyPath: WritableKeyPath<Object, Value?>) -> Value? {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath.
    func animationVelocity<Value: AnimatableData>(for keyPath: KeyPath<PropertyAnimator, Value>) -> Value? {
        if let animation = self.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        } else if let animation = (object as? WaveView)?.optionalLayer?.animator.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        }
        return nil
    }
    
    /// The current animation velocity of the specified keypath, or `nil` if there isn't an animation for the keypath.
    func animationVelocity<Value: AnimatableData>(for keyPath: KeyPath<PropertyAnimator, Value?>) -> Value? {
        if let animation = self.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        } else if let animation = (object as? WaveView)?.optionalLayer?.animator.animations[keyPath.stringValue] as? SpringAnimator<Value> {
            return animation.velocity
        }
        return nil
    }
}

internal extension PropertyAnimator {
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
    
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> SpringAnimator<Val>? {
        return animations[key ?? keyPath.stringValue] as? SpringAnimator<Val>
    }
    
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func value<Value: AnimatableData>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value?  {
        return animation(for: keyPath, key: key)?.target ?? object[keyPath: keyPath]
    }
    
    func setValue<Value: AnimatableData>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        
        if Value.self == CGColor.self {
            let iniVal = (initialValue as! CGColor).waveColor
            let tarVal = (newValue as! CGColor).waveColor
            if iniVal?.isVisible == false || iniVal == nil {
                initialValue = (tarVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
            }
            if tarVal?.isVisible == false || tarVal == nil {
                targetValue = (iniVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
            }
        }
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)

        let animation = (animation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        animation.configure(withSettings: settings)
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
        }
        animation.target = targetValue
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
        }
        let groupUUID = animation.groupUUID
        let animationKey = key ?? keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    func setValue<Value: AnimatableData>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, completion: (()->())? = nil)  {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.animate(withSpring: .nonAnimated) {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.spring == .nonAnimated && animation(for: keyPath, key: key) != nil) else {
            return
        }
        
        var initialValue = object[keyPath: keyPath] ?? Value.zero
        var targetValue = newValue ?? Value.zero
        
        if Value.self == CGColor.self {
            let iniVal = (object[keyPath: keyPath] as! Optional<CGColor>)?.waveColor
            let tarVal = (newValue as! Optional<CGColor>)?.waveColor
            if iniVal?.isVisible == false || iniVal == nil {
                initialValue = (tarVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
            }
            if tarVal?.isVisible == false || tarVal == nil {
                targetValue = (iniVal?.withAlphaComponent(0.0).cgColor ?? .clear) as! Value
            }
        }
                
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        let animation = (animation(for: keyPath, key: key) ?? SpringAnimator<Value>(spring: settings.spring, value: initialValue, target: targetValue))
        animation.configure(withSettings: settings)
        if let gestureVelocity = settings.gestureVelocity {
            (animation as? SpringAnimator<CGRect>)?.velocity.origin = gestureVelocity
            (animation as? SpringAnimator<CGPoint>)?.velocity = gestureVelocity
        }
        animation.target = targetValue
        animation.valueChanged = { [weak self] value in
            self?.object[keyPath: keyPath] = value
        }
        let groupUUID = animation.groupUUID
        let animationKey = key ?? keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
}




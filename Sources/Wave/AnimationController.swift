//
//  AnimationController.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import UIKit

internal class AnimationController {

    static let shared = AnimationController()

    private var displayLink: CADisplayLink?

    private var animations: [UUID: AnimatorProviding] = [:]
    private var animationSettingsStack = SettingsStack()

    typealias CompletionBlock = ((_ finished: Bool, _ retargeted: Bool) -> Void)
    var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

    var currentAnimationParameters: AnimationParameters? {
        animationSettingsStack.currentSettings
    }

    func runAnimationBlock(
        settings: AnimationParameters,
        animations: (() -> Void),
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil) {
            // Register the handler
            groupAnimationCompletionBlocks[settings.groupUUID] = completion

            animationSettingsStack.push(settings: settings)
            animations()
            animationSettingsStack.pop()
    }

    func runPropertyAnimation(_ animation: AnimatorProviding) {
        if animations.isEmpty {
            startDisplayLink()
        }

        animations[animation.id] = animation
    }

    @objc
    private func updateAnimations() {
        guard let displayLink = displayLink else {
            fatalError("Can't update animations without a display link")
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let dt = (displayLink.targetTimestamp - displayLink.timestamp)

        let sortedAnimations = animations.values.sorted { lhs, rhs in
            lhs.relativePriority > rhs.relativePriority
        }

        for animation in sortedAnimations {
            if animation.state == .ended {
                animation.reset()
                animations.removeValue(forKey: animation.id)
            } else {
                animation.updateAnimation(dt: dt)
            }
        }

        CATransaction.commit()

        if animations.isEmpty {
            stopDisplayLink()
        }
    }

    private func startDisplayLink() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(updateAnimations))

            guard let displayLink = displayLink else {
                print("[Wave] Unable to create display link.")
                return
            }

            displayLink.add(to: .current, forMode: .common)

            if #available(iOS 15.0, *) {
                let maximumFramesPerSecond = Float(UIScreen.main.maximumFramesPerSecond)
                let highFPSEnabled = maximumFramesPerSecond > 60
                let minimumFPS: Float = highFPSEnabled ? 80 : 60
                displayLink.preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
            }
        }
    }

    private func stopDisplayLink() {
        displayLink?.remove(from: .current, forMode: .common)
        displayLink = nil
    }

    internal func executeHandler(uuid: UUID?, finished: Bool, retargeted: Bool) {
        guard let uuid = uuid, let block = groupAnimationCompletionBlocks[uuid] else {
            return
        }

        block(finished, retargeted)

        groupAnimationCompletionBlocks.removeValue(forKey: uuid)
    }

}

extension AnimationController {

    struct AnimationParameters {
        let groupUUID: UUID
        let spring: Spring
        let mode: AnimationMode
        let delay: CGFloat
        let gestureVelocity: CGPoint?

        let completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)?
    }

    private class SettingsStack {
        private var stack: [AnimationParameters] = []

        var currentSettings: AnimationParameters? {
            stack.last
        }

        func push(settings: AnimationParameters) {
            stack.append(settings)
        }

        func pop() {
            stack.removeLast()
        }
    }
}

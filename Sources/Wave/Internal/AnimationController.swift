//
//  AnimationController.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import QuartzCore

#if os(iOS)
import UIKit
typealias DisplayLinkProvider = CADisplayLinkProvider
#elseif os(macOS)
import AppKit
import CoreVideo
typealias DisplayLinkProvider = CVDisplayLinkProvider
#endif

internal class AnimationController {

    static let shared = AnimationController()

    private lazy var displayLinkProvider: DisplayLinkProvider = {
        DisplayLinkProvider { [weak self] dt in
            guard let strongSelf = self else { return }

            let scheduledAnimations = Array(strongSelf.animations.values)
            strongSelf.withoutImplicitAnimations {
                for animation in scheduledAnimations {
                    // The snapshot can include animations that finished or
                    // were reset earlier in this frame, before we prune them.
                    if animation.state == .running {
                        animation.updateAnimation(dt: dt)
                    }
                }
            }

            strongSelf.pruneScheduledAnimations(scheduledAnimations)
            strongSelf.updateDisplayLinkState()
        }
    }()

    private var animations: [UUID: AnimatorProviding] = [:]

    private var animationSettingsStack = SettingsStack()

    typealias CompletionBlock = ((_ finished: Bool, _ retargeted: Bool) -> Void)
    private var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

    var currentAnimationParameters: AnimationParameters? {
        animationSettingsStack.currentSettings
    }

    func currentAnimationParametersOrImplicitNonAnimated() -> AnimationParameters {
        if let settings = currentAnimationParameters {
            return settings
        }

        // Using `.animator` outside an explicit `Wave.animate` block should not
        // recursively create a brand new animation block per property write.
        // Fall back to the default immediate semantics directly instead.
        return AnimationParameters(
            groupUUID: UUID(),
            spring: .defaultNonAnimated,
            mode: .nonAnimated,
            gestureVelocity: nil,
            completion: nil
        )
    }

    func runAnimationBlock(
        settings: AnimationParameters,
        animations: (() -> Void),
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil) {
            // Register the handler
            groupAnimationCompletionBlocks[settings.groupUUID] = completion

            animationSettingsStack.push(settings: settings)

            withoutImplicitAnimations {
                animations()
            }

            animationSettingsStack.pop()
        }

    func runPropertyAnimation(_ animation: AnimatorProviding) {
        animations[animation.id] = animation

        // The initial `dt == 0` update should use the same disabled-actions
        // transaction as display-link ticks so update blocks behave consistently.
        if animation.requiresInitialUpdateOnStart {
            withoutImplicitAnimations {
                animation.updateAnimation(dt: .zero)
            }
        }

        if animation.state == .running {
            // The common path is a running animation or retarget, and in high-
            // frequency gesture code there may be hundreds of these per update.
            // Avoid a full controller rescan here; only ensure the display link
            // is active for the running work we already know about.
            displayLinkProvider.start()
        } else {
            // Non-animated or immediately-finished runs should be unscheduled
            // right away instead of lingering until a future display-link
            // cleanup pass.
            pruneScheduledAnimations([animation])
            updateDisplayLinkState()
        }

    }

    internal func executeHandler(uuid: UUID?, finished: Bool, retargeted: Bool) {
        guard let uuid, let block = groupAnimationCompletionBlocks[uuid] else {
            return
        }

        block(finished, retargeted)

        groupAnimationCompletionBlocks.removeValue(forKey: uuid)
    }

    func performImmediatePropertyChange(groupUUID: UUID?, updates: () -> Void) {
        withoutImplicitAnimations(updates)
        executeHandler(uuid: groupUUID, finished: true, retargeted: false)
    }

    func withoutImplicitAnimations(_ updates: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updates()
        CATransaction.commit()
    }

    internal var scheduledAnimationCount: Int {
        animations.count
    }

    internal var isDisplayLinkRunning: Bool {
        displayLinkProvider.isRunning
    }

    private func pruneScheduledAnimations(_ animationsToCheck: [AnimatorProviding]) {
        for animation in animationsToCheck {
            if animation.state != .running {
                animation.reset()
                animations.removeValue(forKey: animation.id)
            }
        }
    }

    private func updateDisplayLinkState() {
        if animations.isEmpty {
            displayLinkProvider.stop()
        } else {
            displayLinkProvider.start()
        }
    }
}

extension AnimationController {

    struct AnimationParameters {
        let groupUUID: UUID
        let spring: Spring
        let mode: AnimationMode
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

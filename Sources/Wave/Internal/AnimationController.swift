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

            strongSelf.withoutImplicitAnimations {
                for animation in strongSelf.animations.values {
                    if animation.state != .running {
                        animation.reset()
                        strongSelf.animations.removeValue(forKey: animation.id)
                    } else {
                        animation.updateAnimation(dt: dt)
                    }
                }
            }

            if strongSelf.animations.isEmpty {
                strongSelf.displayLinkProvider.stop()
            }
        }
    }()

    private var animations: [UUID: AnimatorProviding] = [:]

    private var animationSettingsStack = SettingsStack()

    typealias CompletionBlock = ((_ finished: Bool, _ retargeted: Bool) -> Void)
    private var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

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
            displayLinkProvider.start()
        }

        animations[animation.id] = animation

        // The initial `dt == 0` update should use the same disabled-actions
        // transaction as display-link ticks so update blocks behave consistently.
        withoutImplicitAnimations {
            animation.updateAnimation(dt: .zero)
        }
    }

    internal func executeHandler(uuid: UUID?, finished: Bool, retargeted: Bool) {
        guard let uuid = uuid, let block = groupAnimationCompletionBlocks[uuid] else {
            return
        }

        block(finished, retargeted)

        groupAnimationCompletionBlocks.removeValue(forKey: uuid)
    }

    private func withoutImplicitAnimations(_ updates: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updates()
        CATransaction.commit()
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

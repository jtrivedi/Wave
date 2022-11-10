//
//  AnimationProviding.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

internal protocol AnimatorProviding {
    var id: UUID { get }
    var groupUUID: UUID? { get }

    var state: AnimatorState { get }

    func updateAnimation(dt: TimeInterval)

    func start(afterDelay delay: TimeInterval)
    func stop(immediately: Bool)

    func reset()

    var mode: AnimationMode { get set }
}

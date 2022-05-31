//
//  AnimationProviding.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

internal protocol AnimationProviding {
    var id: UUID { get }
    var groupUUID: UUID? { get }

    var state: AnimationState { get }

    func updateAnimation(dt: TimeInterval)

    func start(afterDelay delay: TimeInterval)
    func stop(immediately: Bool)

    func reset()

    var mode: AnimationMode { get set }

    var relativePriority: Int { get set }
}

//
//  TestUtilities.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import XCTest
@testable import Wave

public extension XCTestCase {
    func wait(for spring: Spring, block: (() -> Void)) {
        let exp = expectation(description: "Waiting for spring to settle")
        let result = XCTWaiter.wait(for: [exp], timeout: spring.settlingDuration * 1.5)
        if result == XCTWaiter.Result.timedOut {
            block()
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func waitForAnimationControllerToBecomeIdle(timeout: TimeInterval = 1.0) {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if AnimationController.shared.scheduledAnimationCount == 0,
               !AnimationController.shared.isDisplayLinkRunning {
                return
            }

            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
        }

        XCTFail("AnimationController did not become idle within \(timeout) seconds")
    }

}

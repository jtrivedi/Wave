//
//  TestUtilities.swift
//  
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

}

//
//  SpringTests.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import XCTest
@testable import Wave

final class SpringTests: XCTestCase {

    let epsilon = 0.0001
    let dt = (1.0 / 60.0)

    func testCriticallyDampedSpring() throws {
        let s = Spring(dampingRatio: 1.0, response: 0.8)

        XCTAssertEqual(s.dampingRatio, 1.0)
        XCTAssertEqual(s.response, 0.8)
        XCTAssertEqual(s.mass, 1.0)

        XCTAssertEqual(s.stiffness, 61.6850, accuracy: epsilon)
        XCTAssertEqual(s.dampingCoefficient, 15.7079, accuracy: epsilon)

        let durationBoost = 1.25
        XCTAssertEqual(s.settlingDuration, 1.17269 * durationBoost, accuracy: epsilon)
    }

    func testUnderdampedSpring() throws {
        let s = Spring(dampingRatio: 0.6, response: 0.8)

        XCTAssertEqual(s.dampingRatio, 0.6)
        XCTAssertEqual(s.response, 0.8)
        XCTAssertEqual(s.mass, 1.0)

        XCTAssertEqual(s.stiffness, 61.6850, accuracy: epsilon)
        XCTAssertEqual(s.dampingCoefficient, 9.4247, accuracy: epsilon)

        XCTAssertEqual(s.settlingDuration, 1.9544, accuracy: epsilon)
    }

    func testResponseAndStiffness() throws {
        let dampingRatio = 0.6
        let a = Spring(dampingRatio: dampingRatio, response: 0.8)
        let b = Spring(dampingRatio: dampingRatio, stiffness: a.stiffness)
        let c = Spring(dampingRatio: dampingRatio, response: a.response)

        XCTAssertEqual(a, b)
        XCTAssertEqual(b, c)
    }

    func testZeroResponseSpring() throws {
        let zeroResponseSpring = Spring(dampingRatio: 1.0, response: 0.0)
        XCTAssertEqual(zeroResponseSpring.response, 0)
        XCTAssertEqual(zeroResponseSpring.stiffness, .infinity)
        XCTAssertEqual(zeroResponseSpring.settlingDuration, 1.0)
    }

    func testResponseDuration() throws {
        let tightSpring = Spring(dampingRatio: 1.0, response: 0.2)
        let looseSpring = Spring(dampingRatio: 1.0, response: 0.8)
        XCTAssertGreaterThan(looseSpring.settlingDuration, tightSpring.settlingDuration)
    }

    func testEqualSprings() throws {
        let a = Spring(dampingRatio: 0.6, response: 0.8)
        let b = Spring(dampingRatio: 0.6, response: 0.8)

        XCTAssertEqual(a, b)
    }

    func testSpringCalculationPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            let spring = Spring(dampingRatio: 0.15, response: 10)
            let scalarAnimation = Animation<CGFloat>(spring: spring, value: 0, target: 100)
            // 97 seconds
            let settlingDuration = spring.settlingDuration

            // 5863 frames at 60fps
            let frames = Int(settlingDuration * 60)

            // Executes 5863 frames in 0.004 seconds (4ms)
            // or 1,465,750 spring calculations per second
            //
            for _ in 0...frames {
                scalarAnimation.updateAnimation(dt: dt)
            }
        }
    }

}

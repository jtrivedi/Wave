//
//  SpringTests.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import XCTest
import QuartzCore
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
            let scalarAnimator = SpringAnimator<CGFloat>(spring: spring, value: 0, target: 100)
            // 97 seconds
            let settlingDuration = spring.settlingDuration

            // 5863 frames at 60fps
            let frames = Int(settlingDuration * 60)

            // Executes 5863 frames in 0.004 seconds (4ms)
            // or 1,465,750 spring calculations per second
            //
            for _ in 0...frames {
                scalarAnimator.updateAnimation(dt: dt)
            }
        }
    }

    func testResetRemovesAnimatorFromControllerOnNextTick() {
        let staleCallbackExpectation = expectation(description: "Stale valueChanged should not fire after reset")
        staleCallbackExpectation.isInverted = true

        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.value = 0
        animator.target = 1

        var callbackCount = 0
        animator.valueChanged = { _ in
            callbackCount += 1

            if callbackCount == 1 {
                animator.stop(immediately: true)
                animator.reset()
            } else {
                staleCallbackExpectation.fulfill()
            }
        }

        animator.start()

        wait(for: [staleCallbackExpectation], timeout: 0.2)
        XCTAssertEqual(callbackCount, 1)
        XCTAssertEqual(animator.state, .inactive)
    }

    func testNonAnimatedStartDoesNotLeaveAnimatorScheduled() {
        waitForAnimationControllerToBecomeIdle()

        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.mode = .nonAnimated
        animator.value = 0
        animator.target = 1

        animator.start()

        XCTAssertEqual(animator.value, 1)
        XCTAssertEqual(AnimationController.shared.scheduledAnimationCount, 0)
        XCTAssertFalse(AnimationController.shared.isDisplayLinkRunning)
    }

    func testInitialStartCallbackRunsWithImplicitAnimationsDisabled() {
        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.value = 0
        animator.target = 1

        let callbackExpectation = expectation(description: "Initial callback runs")
        var disableActionsValues: [Bool] = []

        animator.valueChanged = { _ in
            disableActionsValues.append(CATransaction.disableActions())
            animator.stop(immediately: true)
            callbackExpectation.fulfill()
        }

        animator.start()

        wait(for: [callbackExpectation], timeout: 1.0)

        XCTAssertEqual(disableActionsValues, [true])
    }

    func testImmediateStopFreezesValueAndZeroesVelocityUntilRestart() throws {
        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.value = 0
        animator.target = 1

        let stoppedExpectation = expectation(description: "Animator stopped")
        var stoppedValue: CGFloat?

        animator.valueChanged = { value in
            if value > 0.2 {
                stoppedValue = value
                animator.stop(immediately: true)
                stoppedExpectation.fulfill()
            }
        }

        animator.start()

        wait(for: [stoppedExpectation], timeout: 1.0)

        let frozenValue = try XCTUnwrap(stoppedValue)

        wait(for: .defaultAnimated) {
            XCTAssertEqual(animator.state, .inactive)
            XCTAssertEqual(animator.value, frozenValue)
            XCTAssertEqual(animator.target, 1)
            XCTAssertEqual(animator.velocity, .zero)
        }
    }

    func testAnimatorCanRestartImmediatelyAfterStop() {
        let restartedExpectation = expectation(description: "Animator restarts and uses the new callback")

        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.value = 0
        animator.target = 1

        var phase = 0
        var secondRunValues: [CGFloat] = []
        var fulfilledRestartExpectation = false

        animator.valueChanged = { value in
            if phase == 0, value > 0.2 {
                phase = 1
                animator.stop(immediately: true)

                animator.value = value
                animator.target = 0
                animator.valueChanged = { newValue in
                    secondRunValues.append(newValue)

                    if !fulfilledRestartExpectation, newValue < value {
                        fulfilledRestartExpectation = true
                        animator.stop(immediately: true)
                        animator.reset()
                        restartedExpectation.fulfill()
                    }
                }

                animator.start()
            }
        }

        animator.start()

        wait(for: [restartedExpectation], timeout: 1.0)
        XCTAssertFalse(secondRunValues.isEmpty)
        XCTAssertEqual(animator.target, 0)
    }

    func testAnimatorCanRestartFromFinishedCompletion() throws {
        let spring = Spring(dampingRatio: 1.0, response: 0.15)
        let animator = SpringAnimator<CGFloat>(spring: spring)
        animator.value = 0
        animator.target = 1

        let restartedExpectation = expectation(description: "Animator restarts cleanly from a finished completion")

        var phase = 0
        var firstCompletedValue: CGFloat?
        var completionVelocity: CGFloat?
        var secondRunFirstValue: CGFloat?
        var secondRunValues: [CGFloat] = []

        animator.completion = { event in
            guard case .finished(let value) = event else { return }

            if phase == 0 {
                phase = 1
                firstCompletedValue = value
                completionVelocity = animator.velocity

                animator.value = value
                animator.target = 0
                animator.valueChanged = { newValue in
                    secondRunFirstValue = secondRunFirstValue ?? newValue
                    secondRunValues.append(newValue)

                    if newValue < value {
                        animator.stop(immediately: true)
                        animator.reset()
                        restartedExpectation.fulfill()
                    }
                }

                animator.start()
            }
        }

        animator.start()

        wait(for: [restartedExpectation], timeout: 1.0)

        let completedValue = try XCTUnwrap(firstCompletedValue)
        let terminalVelocity = try XCTUnwrap(completionVelocity)
        let firstValue = try XCTUnwrap(secondRunFirstValue)

        XCTAssertEqual(terminalVelocity, .zero, accuracy: epsilon)
        XCTAssertEqual(firstValue, completedValue, accuracy: epsilon)
        XCTAssertGreaterThan(secondRunValues.count, 1)
    }

    func testMidFlightRetargetEmitsSingleRetargetedThenFinishedAtNewTarget() {
        let spring = Spring(dampingRatio: 1.0, response: 0.15)
        let animator = SpringAnimator<CGFloat>(spring: spring)
        animator.value = 0
        animator.target = 1

        let retargetExpectation = expectation(description: "Animator retargets once")
        let finishedExpectation = expectation(description: "Animator finishes at new target")
        let duplicateRetargetExpectation = expectation(description: "Animator should not retarget twice")
        let duplicateFinishedExpectation = expectation(description: "Animator should not finish twice")
        duplicateRetargetExpectation.isInverted = true
        duplicateFinishedExpectation.isInverted = true

        var phase = 0
        var retargetEvents: [(from: CGFloat, to: CGFloat)] = []
        var finishedValues: [CGFloat] = []

        animator.completion = { event in
            switch event {
            case .retargeted(let from, let to):
                retargetEvents.append((from, to))

                if retargetEvents.count == 1 {
                    retargetExpectation.fulfill()
                } else {
                    duplicateRetargetExpectation.fulfill()
                }
            case .finished(let value):
                finishedValues.append(value)

                if finishedValues.count == 1 {
                    finishedExpectation.fulfill()
                } else {
                    duplicateFinishedExpectation.fulfill()
                }
            }
        }

        animator.valueChanged = { value in
            if phase == 0, value > 0.2 {
                phase = 1
                animator.target = 2
            }
        }

        animator.start()

        wait(for: [retargetExpectation, finishedExpectation], timeout: 2.0)
        wait(for: [duplicateRetargetExpectation, duplicateFinishedExpectation], timeout: 0.1)

        XCTAssertEqual(retargetEvents.count, 1)
        XCTAssertEqual(retargetEvents.first?.from ?? .nan, 1, accuracy: epsilon)
        XCTAssertEqual(retargetEvents.first?.to ?? .nan, 2, accuracy: epsilon)
        XCTAssertEqual(finishedValues.count, 1)
        XCTAssertEqual(finishedValues.first ?? .nan, 2, accuracy: epsilon)
    }

    func testRetargetedAndFinishedCallbacksObserveExpectedStates() {
        let spring = Spring(dampingRatio: 1.0, response: 0.15)
        let animator = SpringAnimator<CGFloat>(spring: spring)
        animator.value = 0
        animator.target = 1

        let retargetExpectation = expectation(description: "Retarget callback sees running state")
        let finishedExpectation = expectation(description: "Finished callback sees ended state")

        var phase = 0
        var retargetState: AnimatorState?
        var finishedState: AnimatorState?

        animator.completion = { event in
            switch event {
            case .retargeted:
                retargetState = animator.state
                retargetExpectation.fulfill()
            case .finished:
                finishedState = animator.state
                finishedExpectation.fulfill()
            }
        }

        animator.valueChanged = { value in
            if phase == 0, value > 0.2 {
                phase = 1
                animator.target = 2
            }
        }

        animator.start()

        wait(for: [retargetExpectation, finishedExpectation], timeout: 2.0)

        XCTAssertEqual(retargetState, .running)
        XCTAssertEqual(finishedState, .ended)
    }

    func testFinalValueChangedStopDoesNotEmitDuplicateFinishedCompletion() {
        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.mode = .nonAnimated
        animator.value = 0
        animator.target = 1

        let finishedExpectation = expectation(description: "Animator finishes once")
        let duplicateFinishedExpectation = expectation(description: "Animator should not finish twice")
        duplicateFinishedExpectation.isInverted = true

        var finishedValues: [CGFloat] = []

        animator.completion = { event in
            guard case .finished(let value) = event else { return }

            finishedValues.append(value)

            if finishedValues.count == 1 {
                finishedExpectation.fulfill()
            } else {
                duplicateFinishedExpectation.fulfill()
            }
        }

        animator.valueChanged = { _ in
            animator.stop(immediately: true)
        }

        animator.start()

        wait(for: [finishedExpectation], timeout: 1.0)
        wait(for: [duplicateFinishedExpectation], timeout: 0.1)

        XCTAssertEqual(finishedValues, [1])
    }

    func testFinalValueChangedRetargetDoesNotEmitStaleFinishedCompletion() {
        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.mode = .nonAnimated
        animator.value = 0
        animator.target = 1

        let retargetExpectation = expectation(description: "Animator retargets")
        let finishedExpectation = expectation(description: "Animator finishes at the new target")
        let staleFinishedExpectation = expectation(description: "Animator should not finish at the stale target")
        staleFinishedExpectation.isInverted = true

        var phase = 0
        var finishedValues: [CGFloat] = []

        animator.completion = { event in
            switch event {
            case .retargeted(let from, let to):
                XCTAssertEqual(from, 1)
                XCTAssertEqual(to, 2)
                retargetExpectation.fulfill()
            case .finished(let value):
                finishedValues.append(value)

                if value == 1 {
                    staleFinishedExpectation.fulfill()
                } else if value == 2 {
                    finishedExpectation.fulfill()
                }
            }
        }

        animator.valueChanged = { value in
            if phase == 0 {
                phase = 1
                XCTAssertEqual(value, 1)
                animator.target = 2
            }
        }

        animator.start()

        wait(for: [retargetExpectation, finishedExpectation], timeout: 1.0)
        wait(for: [staleFinishedExpectation], timeout: 0.1)

        XCTAssertEqual(finishedValues, [2])
    }

    func testDeferredStopRetargetsToCurrentValueThenFinishes() throws {
        let spring = Spring(dampingRatio: 1.0, response: 0.15)
        let animator = SpringAnimator<CGFloat>(spring: spring)
        animator.value = 0
        animator.target = 1

        let retargetExpectation = expectation(description: "Deferred stop retargets to current value")
        let finishedExpectation = expectation(description: "Deferred stop finishes at the captured value")

        var phase = 0
        var stopValue: CGFloat?
        var retargetState: AnimatorState?
        var finishedState: AnimatorState?
        var retargetEvent: (from: CGFloat, to: CGFloat)?
        var finishedValue: CGFloat?

        animator.completion = { event in
            switch event {
            case .retargeted(let from, let to):
                retargetState = animator.state
                retargetEvent = (from, to)
                retargetExpectation.fulfill()
            case .finished(let value):
                finishedState = animator.state
                finishedValue = value
                finishedExpectation.fulfill()
            }
        }

        animator.valueChanged = { value in
            if phase == 0, value > 0.2 {
                phase = 1
                stopValue = value
                animator.stop(immediately: false)
            }
        }

        animator.start()

        wait(for: [retargetExpectation, finishedExpectation], timeout: 1.0)

        let capturedStopValue = try XCTUnwrap(stopValue)
        let event = try XCTUnwrap(retargetEvent)
        let completedValue = try XCTUnwrap(finishedValue)

        XCTAssertEqual(retargetState, .running)
        XCTAssertEqual(finishedState, .ended)
        XCTAssertEqual(event.from, 1, accuracy: epsilon)
        XCTAssertEqual(event.to, capturedStopValue, accuracy: epsilon)
        XCTAssertEqual(completedValue, capturedStopValue, accuracy: epsilon)

        wait(for: spring) {
            XCTAssertEqual(animator.state, .inactive)
            XCTAssertEqual(animator.target ?? .nan, capturedStopValue, accuracy: self.epsilon)
            XCTAssertEqual(animator.velocity, .zero, accuracy: self.epsilon)
        }
    }

    func testStopThenRestartUsesAssignedValueTargetAndVelocity() {
        let animator = SpringAnimator<CGFloat>(spring: .defaultAnimated)
        animator.value = 0
        animator.target = 1
        animator.start()

        animator.stop(immediately: true)

        animator.value = 0.25
        animator.target = 1.5
        animator.velocity = 7.0
        animator.start()

        XCTAssertEqual(animator.state, .running)
        XCTAssertEqual(animator.value, 0.25)
        XCTAssertEqual(animator.target, 1.5)
        XCTAssertEqual(animator.velocity, 7.0)

        animator.stop(immediately: true)
        animator.reset()
    }

}

//
//  DisplayLinkProviding.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation

typealias DisplayLinkCallback = ((_ dt: TimeInterval) -> Void)

protocol DisplayLinkProviding {
    func start()
    func stop()

    init(frameCallback: @escaping DisplayLinkCallback)
}

#if os(iOS)
import UIKit

class CADisplayLinkProvider: DisplayLinkProviding {

    let frameCallback: DisplayLinkCallback
    var displayLinkProvider: CADisplayLink?

    required init(frameCallback: @escaping DisplayLinkCallback) {
        self.frameCallback = frameCallback
    }

    func start() {
        displayLinkProvider = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLinkProvider?.add(to: .current, forMode: .common)

        if #available(iOS 15.0, *) {
            let maximumFramesPerSecond = Float(UIScreen.main.maximumFramesPerSecond)
            let highFPSEnabled = maximumFramesPerSecond > 60
            let minimumFPS: Float = highFPSEnabled ? 80 : 60
            displayLinkProvider?.preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
        }
    }

    func stop() {
        displayLinkProvider?.invalidate()
        displayLinkProvider?.remove(from: .current, forMode: .common)
        displayLinkProvider = nil
    }

    @objc
    func displayLinkFired() {
        guard let displayLinkProvider = displayLinkProvider else {
            fatalError("Can't update animations without a display link")
        }

        let dt = (displayLinkProvider.targetTimestamp - displayLinkProvider.timestamp)
        self.frameCallback(dt)
    }
}

#elseif os(macOS)
import CoreVideo

class CVDisplayLinkProvider: DisplayLinkProviding {

    let frameCallback: DisplayLinkCallback
    var displayLinkProvider: CVDisplayLink?

    required init(frameCallback: @escaping DisplayLinkCallback) {
        self.frameCallback = frameCallback
    }

    func start() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLinkProvider)

        if let displayLinkProvider = displayLinkProvider {
            CVDisplayLinkSetOutputHandler(displayLinkProvider, { [weak self] (_, inNow, inOutputTime, _, _) -> CVReturn in
                let dt = inOutputTime.pointee.timeInterval - inNow.pointee.timeInterval
                self?.frameCallback(dt)
                return kCVReturnSuccess
            })
            CVDisplayLinkStart(displayLinkProvider)
        }
    }

    func stop() {
        if let displayLinkProvider = displayLinkProvider {
            CVDisplayLinkStop(displayLinkProvider)
        }

        displayLinkProvider = nil
    }
}

extension CVTimeStamp {
    var timeInterval: TimeInterval {
        TimeInterval(videoTime) / TimeInterval(videoTimeScale)
    }
}

#endif

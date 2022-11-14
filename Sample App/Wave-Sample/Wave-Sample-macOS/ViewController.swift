//
//  ViewController.swift
//  Wave-Sample-macOS
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Cocoa
import Wave

class ViewController: NSViewController {

    var rounded: Bool = false

    lazy var button: NSButton = {
        let button = NSButton()
        button.title = "Click Me"
        button.wantsLayer = true
        button.isBordered = false
        button.layer?.cornerCurve = .continuous
        button.layer?.backgroundColor = NSColor.systemBlue.cgColor
        button.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        return button
    }()

    @objc
    func handleClick(sender: NSClickGestureRecognizer) {
        rounded.toggle()

        // Animate to the new state
        layoutBox(mode: .animated, shouldRound: rounded)
    }

    func layoutBox(mode: AnimationMode, shouldRound rounded: Bool) {
        Wave.animate(withSpring: Spring(dampingRatio: 0.8, response: 1.2), mode: mode) {
            button.layer?.animator.cornerRadius    = rounded ? 24 : 4
            button.layer?.animator.backgroundColor = rounded ? NSColor.systemGreen.cgColor : NSColor.systemBlue.cgColor
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(button)

        // Configure the button's initial layout/style without animation
        layoutBox(mode: .nonAnimated, shouldRound: rounded)

        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(sender:)))
        button.addGestureRecognizer(clickGesture)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Wave with AppKit"
    }

    override func viewDidLayout() {
        button.setFrameOrigin(CGPoint(
            x: view.bounds.midX - (button.bounds.size.width / 2.0),
            y: view.bounds.midY - (button.bounds.size.height / 2.0)
        ))
    }

}

//
//  GridViewController.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import AppKit
import Wave

class GridViewController: NSViewController {

    let dampingLabel = NSTextField(wrappingLabelWithString: "")
    let responseLabel = NSTextField(wrappingLabelWithString: "")
    let settlingTimeLabel = NSTextField(wrappingLabelWithString: "")

    let dampingSlider = NSSlider()
    let responseSlider = NSSlider()

    var sliderSpring: Spring {
        Spring(
            dampingRatio: Double(dampingSlider.doubleValue),
            response: Double(responseSlider.doubleValue)
        )
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        view.backgroundColor = .white

        setupSliders()
        setupGrid()
        updateGridColors()

        dampingSlider.doubleValue = 0.70
        responseSlider.doubleValue = 0.80

        updateLabels()
    }

    // MARK: - Gesture handling

    @objc
    func handlePanWithBlock(sender: NSPanGestureRecognizer) {
        guard let draggedView = sender.view as? Box else {
            return
        }
        
        draggedView.superview?.addSubview(draggedView)
        let touchLocation = sender.location(in: view)
        let touchVelocity = sender.velocity(in: view)
            
            switch sender.state {
            case .began, .changed:
                let scale = mapRange(touchLocation.y, 0, self.view.bounds.size.height, 0.2, 2.5)
                
                let interactiveSpring = Spring(dampingRatio: 1.0, response: 0.3)
                
                Wave.animate(withSpring: interactiveSpring) {
                    draggedView.animator.center = touchLocation
                    draggedView.animator.scale = CGPoint(x: scale, y: scale)
                }
                
            case .ended, .cancelled:
                Wave.animate(withSpring: self.sliderSpring, gestureVelocity: touchVelocity) {
                    draggedView.animator.center = draggedView.originCenter
                    draggedView.animator.scale = CGPoint(x: 1, y: 1)
                } completion: { finished, retargeted in
                    print("[Ended] completion: finished: \(finished), retargeted: \(retargeted)")
                }
                
            default:
                break
            }
    }

    // MARK: - View setup

    func setupGrid() {
        let totalWidth = view.bounds.size.width

        let size = 80.0
        let columns = Int(totalWidth / size)
        let rows = columns + 1

        let boxWidth = (CGFloat(columns) * size)
        let xPadding = (totalWidth - boxWidth) / (CGFloat(columns + 1))

        for row in 0..<rows {
            for col in 0..<columns {
                let box = Box()
                view.addSubview(box)

                box.frame.origin = CGPoint(
                    x: xPadding + CGFloat(col) * size + CGFloat(col) * xPadding,
                    y: 60 + xPadding + CGFloat(row) * size + CGFloat(row) * xPadding
                ).scaledIntegral

                box.originCenter = box.center

                let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(handlePanWithBlock(sender:)))
                box.addGestureRecognizer(panGestureRecognizer)
            }
        }
    }

    func setupSliders() {
        dampingSlider.minValue = 0
        dampingSlider.maxValue = 1.2

        responseSlider.minValue = 0.05
        responseSlider.maxValue = 3
        dampingSlider.target = self
        responseSlider.target = self
        dampingSlider.action = #selector(dampingChanged(sender:))
        responseSlider.action = #selector(responseChanged(sender:))
        let sliderStack = NSStackView(views: [settlingTimeLabel, dampingLabel, dampingSlider, responseLabel, responseSlider])
        sliderStack.setCustomSpacing(10, after: settlingTimeLabel)
        sliderStack.orientation = .vertical
        sliderStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sliderStack)

        sliderStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        sliderStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        sliderStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }

    func updateGridColors() {
        let boxes = view.subviews.compactMap {
            $0 as? Box
        }

        boxes.forEach {
            let firstBox = boxes.first!
            let lastBox = boxes.last!

            let maxDistance = lastBox.center.distance(to: firstBox.center)
            let distanceFromCenter = $0.center.distance(to: firstBox.center)
            let progress = mapRange(distanceFromCenter, 0, maxDistance, 0, 1)
            $0.backgroundColor = NSColor.systemBlue.blended(withFraction: progress, of: .systemPurple)
        }
    }

    // MARK: - Slider handling

    @objc
    func dampingChanged(sender: NSSlider) {
        updateLabels()
    }

    @objc
    func responseChanged(sender: NSSlider) {
        updateLabels()
    }

    func updateLabels() {
        dampingLabel.stringValue = String(format: "Damping Ratio: %.2f", dampingSlider.doubleValue)
        responseLabel.stringValue = String(format: "Frequency Response: %.2f", responseSlider.doubleValue)
        settlingTimeLabel.stringValue = String(format: "Settling time: %.2f", sliderSpring.settlingDuration)
    }

    // MARK: - Init
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class Box: NSView {
    var originCenter: CGPoint = .zero

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.systemBlue.cgColor
        layer?.cornerCurve = .continuous
        layer?.cornerRadius = (bounds.size.height * 0.2237)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal extension NSColor {
    struct RGBAComponents {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
        init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }
    
    final func rgbaComponents() -> RGBAComponents {
      var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBAComponents(red: red, green: green, blue: blue, alpha: alpha)
    }
}

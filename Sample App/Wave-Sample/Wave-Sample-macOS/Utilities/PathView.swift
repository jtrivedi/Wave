//
//  PathView.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import AppKit

class PathView: NSView {

    private var points: [CGPoint] = [] {
        didSet {
            self.needsDisplay = true
        }
    }

    func add(_ point: CGPoint) {
        if points.count > 300 {
            points.removeFirst()
        }
        points.append(point)
    }

    func reset() {
        points.removeAll()
        self.needsDisplay = true
    }
    
    override func layoutSubtreeIfNeeded() {
        super.layoutSubtreeIfNeeded()
        self.layer?.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let firstPoint = points.first, let context = self.currentContext else {
            return
        }
        
        context.saveGState ()
        context.beginPath()

        context.move(to: firstPoint)

        points.forEach {
            context.addLine(to: $0)
        }

        context.setLineCap(.square)
        context.setStrokeColor(NSColor.systemOrange.cgColor)
        context.setLineWidth(2)
        context.strokePath()
        context.restoreGState ()
    }
}

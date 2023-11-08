//
//  NSView+Extensions.swift
//  
//
//  Created by Florian Zand on 08.11.23.
//

#if os(macOS)
import AppKit

internal extension NSView {
    @objc var alpha: CGFloat {
        get { alphaValue }
        set { alphaValue = newValue }
    }
    
    func insertSubview(_ view: NSUIView, aboveSubview siblingSubview: NSUIView) {
        guard subviews.contains(siblingSubview) else { return }
        addSubview(view, positioned: .above, relativeTo: siblingSubview)
    }
    
    func insertSubview(_ view: NSUIView, belowSubview siblingSubview: NSUIView) {
        guard subviews.contains(siblingSubview) else { return }
        addSubview(view, positioned: .below, relativeTo: siblingSubview)
    }
    
    func insertSubview(_ view: NSUIView, at index: Int) {
        guard index < self.subviews.count else {
            self.addSubview(view)
            return
        }
        var subviews = self.subviews
        subviews.insert(view, at: index)
        self.subviews = subviews
    }
}

#endif

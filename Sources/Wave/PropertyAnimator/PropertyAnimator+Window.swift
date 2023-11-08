//
//  PropertyAnimator+Window.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS)
import AppKit

extension NSWindow: AnimatablePropertyProvider { }

public typealias WindowAnimator = PropertyAnimator<NSWindow>

extension PropertyAnimator where Object: NSWindow {
    /// The background color of the window.
    public var backgroundColor: NSUIColor {
        get { self[\.backgroundColor] }
        set { self[\.backgroundColor] = newValue }
    }
    
    /// The alpha of the window.
    public var alpha: CGFloat {
        get { self[\.alphaValue] }
        set { self[\.alphaValue] = newValue }
    }
    
    /// The frame of the window.
    public var frame: CGRect {
        get { self[\.frame_] }
        set { self[\.frame_] = newValue }
    }
    
    /// The size of the window. Changing the value keeps the window centered. To change the size without centering use the window's frame size.
    public var size: CGSize {
        get { frame.size }
        set { frame.sizeCentered = newValue }
    }
}

fileprivate extension NSWindow {
   @objc dynamic var frame_: CGRect {
        get { frame }
        set { setFrame(newValue, display: false) }
    }
}

#endif

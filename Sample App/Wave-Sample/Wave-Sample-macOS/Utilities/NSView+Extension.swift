//
//  NSView+Extension.swift
//  Wave-Sample-macOS
//
//  Created by Florian Zand on 27.10.23.
//

#if os(macOS)

import AppKit

extension NSView {
    var currentContext : CGContext? {
        get {
            if #available(OSX 10.10, *) {
                return NSGraphicsContext.current?.cgContext
            } else if let contextPointer = NSGraphicsContext.current?.graphicsPort {
                return Unmanaged.fromOpaque(contextPointer).takeUnretainedValue()
            }
            
            return nil
        }
    }
    
    var center: CGPoint {
        get { self.frame.center }
        set { self.frame.center = newValue }
    }
    
    var backgroundColor: NSColor? {
        get { if let cgColor = self.layer?.backgroundColor {
            return NSColor(cgColor: cgColor)
        }
            return nil
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}
#endif

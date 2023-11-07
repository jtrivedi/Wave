//
//  NSValue+Extension.swift
//
//
//  Created by Florian Zand on 07.11.23.
//

#if os(macOS)
import AppKit

extension NSValue {
    /// Creates a new value object containing the specified directional edge insets structure.
    public convenience init(directionalEdgeInsets: NSDirectionalEdgeInsets) {
        var insets = directionalEdgeInsets
        self.init(bytes: &insets, objCType: _getObjCTypeEncoding(NSDirectionalEdgeInsets.self))
    }
    
    /// Returns the directional edge insets structure representation of the value.
    public var directionalEdgeInsetsValue: NSDirectionalEdgeInsets {
        var insets = NSDirectionalEdgeInsets()
        self.getValue(&insets)
        return insets
    }
    
    /// Creates a new value object containing the specified CoreGraphics affine transform structure.
    public convenience init(cgAffineTransform: CGAffineTransform) {
        var transform = cgAffineTransform
        self.init(bytes: &transform, objCType: _getObjCTypeEncoding(CGAffineTransform.self))
    }
    
    /// Returns the CoreGraphics affine transform representation of the value.
    public var cgAffineTransformValue: CGAffineTransform {
        var transform = CGAffineTransform.identity
        self.getValue(&transform)
        return transform
    }
}
#endif

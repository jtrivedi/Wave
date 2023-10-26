//
//  NSScrollView+Extension.swift
//
//
//  Created by Florian Zand on 22.05.22.
//

#if os(macOS)
import AppKit

public extension NSScrollView {
    
    /**
     The point at which the origin of the content view is offset from the origin of the scroll view.
     
     The default value is CGPointZero.
     */
    @objc dynamic var contentOffset: CGPoint {
        get { return documentVisibleRect.origin }
        set {  documentView?.scroll(newValue) }
    }
}
#endif

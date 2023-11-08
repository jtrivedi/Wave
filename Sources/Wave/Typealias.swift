//
//  Wave Typealias.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import SwiftUI

#if os(macOS)
import AppKit
public typealias NSUIColor = NSColor
public typealias NSUIView = NSView
public typealias NSUITextField = NSTextField
public typealias NSUIScrollView = NSScrollView
public typealias NSUITextView = NSTextView
internal typealias NSUIEdgeInsets = NSEdgeInsets
#elseif canImport(UIKit)
import UIKit
public typealias NSUIColor = UIColor
public typealias NSUIView = UIView
public typealias NSUITextField = UITextField
public typealias NSUIScrollView = UIScrollView
public typealias NSUITextView = UITextView
internal typealias NSUIEdgeInsets = UIEdgeInsets
#endif

//
//  Wave Typealias.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import SwiftUI

#if os(macOS)
import AppKit
public typealias WaveColor = NSColor
public typealias WaveView = NSView
public typealias WaveTextField = NSTextField
public typealias WaveScrollView = NSScrollView
#elseif canImport(UIKit)
import UIKit
public typealias WaveColor = UIColor
public typealias WaveView = UIView
public typealias WaveTextField = UITextField
public typealias WaveScrollView = UIScrollView
#endif

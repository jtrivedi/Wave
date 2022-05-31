//
//  InstantPanGestureRecognizer.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Foundation
import UIKit

public class InstantPanGestureRecognizer: UIPanGestureRecognizer {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }

}

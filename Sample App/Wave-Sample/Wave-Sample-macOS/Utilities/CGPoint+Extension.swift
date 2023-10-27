//
//  CGPoint+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension CGPoint {
    /**
     Returns a new CGPoint by offsetting the current point by the specified values along the x and y axes.
     
     - Parameters:
     - x: The value to be added to the x-coordinate of the current point.
     - y: The value to be added to the y-coordinate of the current point.
     
     - Returns: The new CGPoint obtained by offsetting the current point by the specified values.
     */
    func offset(xValue: CGFloat = 0, yValue: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + xValue, y: self.y + yValue)
    }
}

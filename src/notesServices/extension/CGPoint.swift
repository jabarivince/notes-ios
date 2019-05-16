//
//  CGPoint.swift
//  notesServices
//
//  Created by jabari on 5/15/19.
//  Copyright © 2019 jabari. All rights reserved.
//

public extension CGPoint {
    /// Euclidian distance between this point
    /// and another specified point.
    func distance(from point: CGPoint) -> CGFloat {
        return CGPoint.distance(from: self, to: point)
    }
    
    /// Returns the euclidian distance between
    /// two points in 2-dimensional cartesian plane.
    static func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = from.x - to.x
        let dy = from.y - to.y
        return ( (dx * dx) + (dy * dy) ).squareRoot()
    }
}

//
//  PCS.swift
//  PCS
//
//  Created by Nicky Taylor on 8/23/24.
//

import Foundation

let epsilon: Float = 0.00001
let pi = Float.pi
let pi2 = Float.pi * 2.0
let pi_2 = Float.pi / 2.0

struct Point {
    var x: Float
    var y: Float
    
    func distanceSquaredTo(_ point: Point) -> Float {
        distanceSquaredTo(point.x, point.y)
    }
    
    func distanceSquaredTo(_ x: Float, _ y: Float) -> Float {
        let diffX = self.x - x
        let diffY = self.y - y
        return diffX * diffX + diffY * diffY
    }
}

protocol LineSegment: AnyObject {
    var x1: Float { set get }
    var y1: Float { set get }
    var x2: Float { set get }
    var y2: Float { set get }
}

protocol PrecomputedLineSegment: LineSegment {
    
    var centerX: Float { get set }
    var centerY: Float { get set }
    
    var directionX: Float { set get }
    var directionY: Float { set get }
    
    var normalX: Float { set get }
    var normalY: Float { set get }
    
    var lengthSquared: Float { set get }
    var length: Float { set get }
    
    var directionAngle: Float { set get }
    var normalAngle: Float { set get }
    
    var isIllegal: Bool { get set }
    
    func precompute()
}

extension PrecomputedLineSegment {
    var p1: Point {
        get {
            Point(x: x1, y: y1)
        }
        set {
            x1 = newValue.x
            y1 = newValue.y
        }
    }
    
    var p2: Point {
        get {
            Point(x: x2, y: y2)
        }
        set {
            x2 = newValue.x
            y2 = newValue.y
        }
    }
    
    var center: Point {
        get {
            Point(x: centerX, y: centerY)
        }
        set {
            centerX = newValue.x
            centerY = newValue.y
        }
    }
    
    func closestPoint(_ point: Point) -> Point {
        var result = Point(x: x1, y: y1)
        let factor1X = point.x - x1
        let factor1Y = point.y - y1
        if lengthSquared > epsilon {
            let scalar = directionX * factor1X + directionY * factor1Y
            if scalar <= 0.0 {
                // stay at p1
            } else if scalar >= length {
                result.x = x2
                result.y = y2
            } else {
                result.x = x1 + directionX * scalar
                result.y = y1 + directionY * scalar
            }
        }
        return result
    }
    
    func closestPoint(_ x: Float, _ y: Float) -> Point {
        var result = Point(x: x1, y: y1)
        let factor1X = x - x1
        let factor1Y = y - y1
        if lengthSquared > epsilon {
            let scalar = directionX * factor1X + directionY * factor1Y
            if scalar <= 0.0 {
                // stay at p1
            } else if scalar >= length {
                result.x = x2
                result.y = y2
            } else {
                result.x = x1 + directionX * scalar
                result.y = y1 + directionY * scalar
            }
        }
        return result
    }
    
    func closestPoint(_ point: Point, _ targetX: inout Float, _ targetY: inout Float) {
        targetX = x1
        targetY = y1
        let factor1X = point.x - x1
        let factor1Y = point.y - y1
        if lengthSquared > epsilon {
            let scalar = directionX * factor1X + directionY * factor1Y
            if scalar <= 0.0 {
                // stay at p1
            } else if scalar >= length {
                targetX = x2
                targetY = y2
            } else {
                targetX = x1 + directionX * scalar
                targetY = y1 + directionY * scalar
            }
        }
    }
    
    func closestPoint(_ x: Float, _ y: Float, _ targetX: inout Float, _ targetY: inout Float) {
        targetX = x1
        targetY = y1
        let factor1X = x - x1
        let factor1Y = y - y1
        if lengthSquared > epsilon {
            let scalar = directionX * factor1X + directionY * factor1Y
            if scalar <= 0.0 {
                // stay at p1
            } else if scalar >= length {
                targetX = x2
                targetY = y2
            } else {
                targetX = x1 + directionX * scalar
                targetY = y1 + directionY * scalar
            }
        }
    }
    
    func distanceSquaredToClosestPoint(_ x: Float, _ y: Float) -> Float {
        let factor1X = x - x1
        let factor1Y = y - y1
        if lengthSquared > epsilon {
            let scalar = directionX * factor1X + directionY * factor1Y
            if scalar <= 0.0 {
                let diffX = x1 - x
                let diffY = y1 - y
                let result = diffX * diffX + diffY * diffY
                return result
            } else if scalar >= length {
                let diffX = x2 - x
                let diffY = y2 - y
                let result = diffX * diffX + diffY * diffY
                return result
            } else {
                let closestX = x1 + directionX * scalar
                let closestY = y1 + directionY * scalar
                let diffX = closestX - x
                let diffY = closestY - y
                let result = diffX * diffX + diffY * diffY
                return result
            }
        }
        return 0.0
    }
    
    func distanceSquaredToPoint(_ point: Point) -> Float {
        let closestPoint = closestPoint(point)
        return closestPoint.distanceSquaredTo(point)
    }
    
    func closestPointIsOnSegment(_ point: Point) -> Bool {
        let factor1X = point.x - x1
        let factor1Y = point.y - y1
        if lengthSquared > epsilon {
            let scalar = directionX * factor1X + directionY * factor1Y
            if scalar < 0.0 || scalar > length {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    func distanceSquaredToLineSegment(_ lineSegment: PrecomputedLineSegment) -> Float {
        
        if lineSegmentIntersectsLineSegment(line1Point1X: x1, line1Point1Y: y1,
                                            line1Point2X: x2, line1Point2Y: y2,
                                            line2Point1X: lineSegment.x1, line2Point1Y: lineSegment.y1,
                                            line2Point2X: lineSegment.x2, line2Point2Y: lineSegment.y2) {
            return 0.0
        }
        
        let cp1_1 = closestPoint(lineSegment.p1)
        let cp1_2 = closestPoint(lineSegment.p2)
        let cp2_1 = lineSegment.closestPoint(p1)
        let cp2_2 = lineSegment.closestPoint(p2)
        
        let distance0 = cp1_1.distanceSquaredTo(cp2_1)
        let distance1 = cp1_1.distanceSquaredTo(cp2_2)
        let distance2 = cp1_2.distanceSquaredTo(cp2_1)
        let distance3 = cp1_2.distanceSquaredTo(cp2_2)
        
        var chosenDistance = distance0
        if distance1 < chosenDistance { chosenDistance = distance1 }
        if distance2 < chosenDistance { chosenDistance = distance2 }
        if distance3 < chosenDistance { chosenDistance = distance3 }
        return chosenDistance
    }
    
    func precompute() {
        center.x = (x1 + x2) * 0.5
        center.y = (y1 + y2) * 0.5
        directionX = x2 - x1
        directionY = y2 - y1
        lengthSquared = directionX * directionX + directionY * directionY
        if lengthSquared > epsilon {
            length = sqrtf(lengthSquared)
            directionX /= length
            directionY /= length
            isIllegal = false
        } else {
            directionX = Float(0.0)
            directionY = Float(-1.0)
            length = 0.0
            isIllegal = true
        }
        
        normalX = -directionY
        normalY = directionX
        
        directionAngle = -atan2f(-directionX, -directionY)
        
        normalAngle = directionAngle + pi_2
        if normalAngle >= pi2 { normalAngle -= pi2 }
        if normalAngle < 0.0 { normalAngle += pi2 }
    }
}

class AnyPrecomputedLineSegment: PrecomputedLineSegment {
    
    init() {
        
    }
    
    var x1: Float = 0.0
    var y1: Float = 0.0
    
    var x2: Float = 0.0
    var y2: Float = 0.0
    
    var isIllegal: Bool = false
    var isTagged: Bool = false
    
    var centerX: Float = 0.0
    var centerY: Float = 0.0
    
    var directionX = Float(0.0)
    var directionY = Float(-1.0)
    
    var normalX = Float(1.0)
    var normalY = Float(0.0)
    
    var lengthSquared = Float(1.0)
    var length = Float(1.0)
    
    var directionAngle = Float(0.0)
    var normalAngle = Float(0.0)
}

func lineSegmentIntersectsLineSegment(line1Point1X: Float,
                                      line1Point1Y: Float,
                                      line1Point2X: Float,
                                      line1Point2Y: Float,
                                      line2Point1X: Float,
                                      line2Point1Y: Float,
                                      line2Point2X: Float,
                                      line2Point2Y: Float) -> Bool {
    
    let area1 = (line1Point2X - line1Point1X) * (line2Point1Y - line1Point1Y) - (line2Point1X - line1Point1X) * (line1Point2Y - line1Point1Y)
    if fabsf(area1) < epsilon {
        if fabsf(line1Point1X - line1Point2X) > epsilon {
            if (line1Point1X <= line2Point1X) && (line2Point1X <= line1Point2X) {
                return true
            } else if (line1Point1X >= line2Point1X) && (line2Point1X >= line1Point2X) {
                return true
            }
        } else {
            if (line1Point1Y <= line2Point1Y) && (line2Point1Y <= line1Point2Y) {
                return true
            } else if (line1Point1Y >= line2Point1Y) && (line2Point1Y >= line1Point2Y) {
                return true
            }
        }
        if fabsf((line1Point2X - line1Point1X) * (line2Point2Y - line1Point1Y) -
                 (line2Point2X - line1Point1X) * (line1Point2Y - line1Point1Y)) < epsilon {
            if fabsf(line2Point1X - line2Point2X) > epsilon {
                if (line2Point1X <= line1Point1X) && (line1Point1X <= line2Point2X) {
                    return true
                } else if (line2Point1X >= line1Point1X) && (line1Point1X >= line2Point2X) {
                    return true
                } else if (line2Point1X <= line1Point2X) && (line1Point2X <= line2Point2X) {
                    return true
                } else if (line2Point1X >= line1Point2X) && (line1Point2X >= line2Point2X) {
                    return true
                }
            } else {
                if (line2Point1Y <= line1Point1Y) && (line1Point1Y <= line2Point2Y) {
                    return true
                } else if (line2Point1Y >= line1Point1Y) && (line1Point1Y >= line2Point2Y) {
                    return true
                } else if (line2Point1Y <= line1Point2Y) && (line1Point2Y <= line2Point2Y) {
                    return true
                } else if (line2Point1Y >= line1Point2Y) && (line1Point2Y >= line2Point2Y) {
                    return true
                }
            }
        }
        return false
    }
    
    let area2 = (line1Point2X - line1Point1X) * (line2Point2Y - line1Point1Y) - (line2Point2X - line1Point1X) * (line1Point2Y - line1Point1Y)
    if fabsf(area2) < epsilon {
        if fabsf(line1Point1X - line1Point2X) > epsilon {
            if (line1Point1X <= line2Point2X) && (line2Point2X <= line1Point2X) {
                return true
            } else if (line1Point1X >= line2Point2X) && (line2Point2X >= line1Point2X) {
                return true
            } else {
                return false
            }
        } else {
            if (line1Point1Y <= line2Point2Y) && (line2Point2Y <= line1Point2Y) {
                return true
            } else if (line1Point1Y >= line2Point2Y) && (line2Point2Y >= line1Point2Y) {
                return true
            } else {
                return false
            }
        }
    }
    
    let area3 = (line2Point2X - line2Point1X) * (line1Point1Y - line2Point1Y) - (line1Point1X - line2Point1X) * (line2Point2Y - line2Point1Y)
    if fabsf(area3) < epsilon {
        
        if fabsf(line2Point1X - line2Point2X) > epsilon {
            if (line2Point1X <= line1Point1X) && (line1Point1X <= line2Point2X) {
                return true
            } else if (line2Point1X >= line1Point1X) && (line1Point1X >= line2Point2X) {
                return true
            }
        } else {
            if (line2Point1Y <= line1Point1Y) && (line1Point1Y <= line2Point2Y) {
                return true
            } else if (line2Point1Y >= line1Point1Y) && (line1Point1Y >= line2Point2Y) {
                return true
            }
        }
        if fabsf((line2Point2X - line2Point1X) * (line1Point2Y - line2Point1Y) -
                 (line1Point2X - line2Point1X) * (line2Point2Y - line2Point1Y)) < epsilon {
            if fabsf(line1Point1X - line1Point2X) > epsilon {
                if (line1Point1X <= line2Point1X) && (line2Point1X <= line1Point2X) {
                    return true
                } else if (line1Point1X >= line2Point1X) && (line2Point1X >= line1Point2X) {
                    return true
                } else if (line1Point1X <= line2Point2X) && (line2Point2X <= line1Point2X) {
                    return true
                } else if (line1Point1X >= line2Point2X) && (line2Point2X >= line1Point2X) {
                    return true
                }
            } else {
                if (line1Point1Y <= line2Point1Y) && (line2Point1Y <= line1Point2Y) {
                    return true
                } else if (line1Point1Y >= line2Point1Y) && (line2Point1Y >= line1Point2Y) {
                    return true
                } else if (line1Point1Y <= line2Point2Y) && (line2Point2Y <= line1Point2Y) {
                    return true
                } else if (line1Point1Y >= line2Point2Y) && (line2Point2Y >= line1Point2Y) {
                    return true
                }
            }
        }
        return false
    }
    let area4 = (line2Point2X - line2Point1X) * (line1Point2Y - line2Point1Y) - (line1Point2X - line2Point1X) * (line2Point2Y - line2Point1Y)
    if fabsf(area4) < epsilon {
        if fabsf(line2Point1X - line2Point2X) > epsilon {
            if (line2Point1X <= line1Point2X) && (line1Point2X <= line2Point2X) {
                return true
            } else if (line2Point1X >= line1Point2X) && (line1Point2X >= line2Point2X) {
                return true
            } else {
                return false
            }
        } else {
            if (line2Point1Y <= line1Point2Y) && (line1Point2Y <= line2Point2Y) {
                return true
            } else if (line2Point1Y >= line1Point2Y) && (line1Point2Y >= line2Point2Y) {
                return true
            } else {
                return false
            }
        }
    }
    return ((area1 > 0.0) != (area2 > 0.0)) && ((area3 > 0.0) != (area4 > 0.0))
}

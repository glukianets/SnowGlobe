import CoreGraphics
import Foundation

extension String: Error { // Never do this in real projects

}

public extension CGRect {
    var topLeft: CGPoint {
        CGPoint(x: self.minX, y: self.minY)
    }

    var topRight: CGPoint {
        CGPoint(x: self.maxX, y: self.minY)
    }

    var bottomLeft: CGPoint {
        CGPoint(x: self.minX, y: self.maxY)
    }

    var bottomRight: CGPoint {
        CGPoint(x: self.maxX, y: self.maxY)
    }

    var midLeft: CGPoint {
        CGPoint(x: self.minX, y: self.midY)
    }

    var midRight: CGPoint {
        CGPoint(x: self.maxX, y: self.midY)
    }

    var topMid: CGPoint {
        CGPoint(x: self.midX, y: self.minY)
    }

    var bottomMid: CGPoint {
        CGPoint(x: self.midX, y: self.maxY)
    }

}

public extension CGVector {
    var magnitude: CGFloat {
        get {
            return sqrt(self.dx * self.dx + self.dy * self.dy)
        }
        set {
            let currentMagnitude = self.magnitude
            let factor: CGFloat = currentMagnitude == 0 ? 0 : newValue / currentMagnitude
            self.dx *= factor
            self.dy *= factor
        }
    }

    var angle: CGFloat {
        get {
            return atan2(self.dy, self.dx)
        }
        set {
            let magnitude = self.magnitude
            self = CGVector(dx: magnitude * cos(newValue), dy: magnitude * sin(newValue))
        }
    }

    var cgPoint: CGPoint {
        get {
            return CGPoint(x: self.dx, y: self.dy)
        }
        set {
            self.dx = newValue.x
            self.dy = newValue.y
        }
    }

    static prefix func - (_ value: CGVector) -> CGVector {
        return CGVector(dx: -value.dx, dy: -value.dy)
    }

    static func - (_ lhs: CGVector, _ rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    static func + (_ lhs: CGVector, _ rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    static func * (_ lhs: CGVector, _ rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }

    static func * (_ lhs: CGFloat, _ rhs: CGVector) -> CGVector {
        return rhs * lhs
    }

    static func / (_ lhs: CGVector, _ rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
    }
}

extension Date {
    mutating func rewind(to date: Date) -> TimeInterval {
        defer { self = date }
        return date.timeIntervalSince(self)
    }

    mutating func rewindToNow() -> TimeInterval {
        self.rewind(to: .now)
    }
}


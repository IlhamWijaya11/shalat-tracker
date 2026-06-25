import Foundation

/// 2D point in **Vision normalized image coordinates**: origin bottom-left,
/// x to the right, y **up**, both in 0...1. (Matches `VNRecognizedPoint`.)
public struct Point2D: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public extension Point2D {
    static func - (a: Point2D, b: Point2D) -> Point2D { Point2D(x: a.x - b.x, y: a.y - b.y) }
    static func + (a: Point2D, b: Point2D) -> Point2D { Point2D(x: a.x + b.x, y: a.y + b.y) }

    var length: Double { (x * x + y * y).squareRoot() }

    static func midpoint(_ a: Point2D, _ b: Point2D) -> Point2D {
        Point2D(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}

/// Body joints from one frame, in Vision normalized coords. All optional because
/// the detector can drop joints (occlusion, out of frame — common during sujud).
public struct BodyJoints: Sendable {
    public var nose: Point2D?
    public var leftEar: Point2D?
    public var rightEar: Point2D?
    public var leftShoulder: Point2D?
    public var rightShoulder: Point2D?
    public var leftHip: Point2D?
    public var rightHip: Point2D?
    public var leftKnee: Point2D?
    public var rightKnee: Point2D?
    public var leftAnkle: Point2D?
    public var rightAnkle: Point2D?

    public init(
        nose: Point2D? = nil,
        leftEar: Point2D? = nil, rightEar: Point2D? = nil,
        leftShoulder: Point2D? = nil, rightShoulder: Point2D? = nil,
        leftHip: Point2D? = nil, rightHip: Point2D? = nil,
        leftKnee: Point2D? = nil, rightKnee: Point2D? = nil,
        leftAnkle: Point2D? = nil, rightAnkle: Point2D? = nil
    ) {
        self.nose = nose
        self.leftEar = leftEar; self.rightEar = rightEar
        self.leftShoulder = leftShoulder; self.rightShoulder = rightShoulder
        self.leftHip = leftHip; self.rightHip = rightHip
        self.leftKnee = leftKnee; self.rightKnee = rightKnee
        self.leftAnkle = leftAnkle; self.rightAnkle = rightAnkle
    }
}

extension BodyJoints {
    /// Midpoint of two optional joints; nil if either side missing.
    func mid(_ a: Point2D?, _ b: Point2D?) -> Point2D? {
        guard let a, let b else { return nil }
        return Point2D.midpoint(a, b)
    }

    var shoulderMid: Point2D? { mid(leftShoulder, rightShoulder) }
    var hipMid: Point2D? { mid(leftHip, rightHip) }
    var ankleMid: Point2D? { mid(leftAnkle, rightAnkle) }
    /// Head reference: nose, else midpoint of ears.
    var head: Point2D? { nose ?? mid(leftEar, rightEar) }
}

import RakaatCore

/// Synthetic joints (Vision normalized coords, y up) for each posture, used by
/// the tests so the whole pipeline runs without a camera.
enum Fixtures {
    static func pair(_ x: Double, _ y: Double, spread: Double = 0.05) -> (Point2D, Point2D) {
        (Point2D(x: x - spread, y: y), Point2D(x: x + spread, y: y))
    }

    static func joints(
        head: Point2D, shoulder: Double, shoulderY: Double,
        hip: Double, hipY: Double, ankleY: Double
    ) -> BodyJoints {
        let (ls, rs) = pair(shoulder, shoulderY)
        let (lh, rh) = pair(hip, hipY)
        let (la, ra) = pair(0.5, ankleY)
        return BodyJoints(
            nose: head,
            leftShoulder: ls, rightShoulder: rs,
            leftHip: lh, rightHip: rh,
            leftAnkle: la, rightAnkle: ra
        )
    }

    static let standing = joints(
        head: Point2D(x: 0.5, y: 0.9),
        shoulder: 0.5, shoulderY: 0.75, hip: 0.5, hipY: 0.5, ankleY: 0.1
    )

    // Bowing: torso tipped toward horizontal, head still high off the floor.
    static let ruku = joints(
        head: Point2D(x: 0.85, y: 0.5),
        shoulder: 0.7, shoulderY: 0.55, hip: 0.5, hipY: 0.5, ankleY: 0.1
    )

    // Prostration: everything low, head near the floor.
    static let sujud = joints(
        head: Point2D(x: 0.72, y: 0.12),
        shoulder: 0.6, shoulderY: 0.2, hip: 0.45, hipY: 0.3, ankleY: 0.1
    )

    // Sitting: torso upright, hips low near ankles.
    static let jalsa = joints(
        head: Point2D(x: 0.5, y: 0.6),
        shoulder: 0.5, shoulderY: 0.45, hip: 0.5, hipY: 0.2, ankleY: 0.1
    )
}

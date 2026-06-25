import XCTest
@testable import RakaatCore

final class PostureClassifierTests: XCTestCase {
    let classifier = PostureClassifier()

    func testClassifiesEachPosture() {
        XCTAssertEqual(classifier.classify(Fixtures.standing), .standing)
        XCTAssertEqual(classifier.classify(Fixtures.ruku), .ruku)
        XCTAssertEqual(classifier.classify(Fixtures.sujud), .sujud)
        XCTAssertEqual(classifier.classify(Fixtures.jalsa), .jalsa)
    }

    func testMissingJointsAreUnknown() {
        XCTAssertEqual(classifier.classify(BodyJoints()), .unknown)
        // Only a head, no torso scale → unknown.
        XCTAssertEqual(classifier.classify(BodyJoints(nose: Point2D(x: 0.5, y: 0.9))), .unknown)
    }

    func testFeaturesStandingIsUpright() throws {
        let f = try XCTUnwrap(PoseFeatures.from(Fixtures.standing))
        XCTAssertLessThan(f.torsoAngle, 20)
        XCTAssertGreaterThan(f.hipAboveAnkle, 0.8)
    }

    func testFeaturesRukuIsTilted() throws {
        let f = try XCTUnwrap(PoseFeatures.from(Fixtures.ruku))
        XCTAssertGreaterThan(f.torsoAngle, 45)
        XCTAssertGreaterThan(f.headAboveAnkle, 0.6)
    }
}

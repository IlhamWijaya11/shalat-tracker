import XCTest
@testable import RakaatCore

/// End-to-end: synthetic joint frames → tracker → session, no camera.
final class RakaatTrackerTests: XCTestCase {

    func testTwoRakaatSubuhEndToEnd() {
        let tracker = RakaatTracker()
        var t = 0.0
        let dt = 0.2

        // Feed a posture's fixture for `seconds`, advancing time.
        func feed(_ joints: BodyJoints, seconds: Double) {
            let frames = Int(seconds / dt)
            for _ in 0..<frames {
                tracker.process(joints: joints, t: t)
                t += dt
            }
        }

        func rakaat() {
            feed(Fixtures.standing, seconds: 2)
            feed(Fixtures.ruku, seconds: 2)
            feed(Fixtures.standing, seconds: 2)  // i'tidal
            feed(Fixtures.sujud, seconds: 2)
            feed(Fixtures.jalsa, seconds: 1.5)
            feed(Fixtures.sujud, seconds: 2)
        }

        rakaat()
        rakaat()
        feed(Fixtures.jalsa, seconds: 8)  // tashahhud → completes

        XCTAssertEqual(tracker.rakaatCount, 2)
        XCTAssertTrue(tracker.isComplete)

        // Subuh time (05:00) → prayer inferred as Subuh.
        var comps = DateComponents()
        comps.year = 2026; comps.month = 6; comps.day = 24; comps.hour = 5; comps.minute = 0
        let date = Calendar.current.date(from: comps)!
        let session = tracker.makeSession(at: date)
        XCTAssertEqual(session.prayer, .subuh)
        XCTAssertEqual(session.rakaat, 2)
    }
}

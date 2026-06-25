import XCTest
@testable import RakaatCore

final class MovementValidatorTests: XCTestCase {
    func testFlagsShortRuku() {
        let v = MovementValidator()
        let violation = v.check(posture: .ruku, duration: 0.4, rakaat: 1)
        XCTAssertEqual(violation, TumaninahViolation(rakaat: 1, posture: .ruku, duration: 0.4))
    }

    func testAcceptsHeldRuku() {
        let v = MovementValidator()
        XCTAssertNil(v.check(posture: .ruku, duration: 1.5, rakaat: 1))
    }

    func testIgnoresUnvalidatedPostures() {
        let v = MovementValidator()
        XCTAssertNil(v.check(posture: .standing, duration: 0.1, rakaat: 1))
    }

    func testStateMachineRecordsRushViolation() {
        let sm = RakaatStateMachine()
        sm.update(posture: .standing, t: 0)
        sm.update(posture: .ruku, t: 2.0)       // ruku starts
        sm.update(posture: .standing, t: 2.4)   // ruku held only 0.4s → flagged
        XCTAssertEqual(sm.violations.count, 1)
        XCTAssertEqual(sm.violations.first?.posture, .ruku)
        XCTAssertEqual(sm.violations.first?.rakaat, 1)
    }
}

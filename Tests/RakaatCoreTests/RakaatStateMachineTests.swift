import XCTest
@testable import RakaatCore

final class RakaatStateMachineTests: XCTestCase {

    /// Builds the posture/time transitions of an n-rakaat prayer, ending in a
    /// long tashahhud sit. Each posture is held ~2s.
    private func sequence(rakaat n: Int) -> [(Posture, Double)] {
        var out: [(Posture, Double)] = []
        var t = 0.0
        func add(_ p: Posture, hold: Double = 2) { out.append((p, t)); t += hold }
        for _ in 0..<n {
            add(.standing)        // qiyam / stand from previous
            add(.ruku)            // the one ruku of this rakaat
            add(.standing)        // i'tidal
            add(.sujud)
            add(.jalsa)
            add(.sujud)
        }
        // Final tashahhud: sit long enough to trigger completion.
        out.append((.jalsa, t)); t += 8
        out.append((.jalsa, t))   // a frame while still sitting → fires complete
        return out
    }

    private func run(_ seq: [(Posture, Double)]) -> RakaatStateMachine {
        let sm = RakaatStateMachine()
        for (p, t) in seq { sm.update(posture: p, t: t) }
        return sm
    }

    func testCountsTwoRakaat() {
        let sm = run(sequence(rakaat: 2))
        XCTAssertEqual(sm.rakaatCount, 2)
        XCTAssertTrue(sm.isComplete)
    }

    func testCountsFourRakaat() {
        let sm = run(sequence(rakaat: 4))
        XCTAssertEqual(sm.rakaatCount, 4)
        XCTAssertTrue(sm.isComplete)
    }

    func testCountsThreeRakaat() {
        let sm = run(sequence(rakaat: 3))
        XCTAssertEqual(sm.rakaatCount, 3)
    }

    func testRukuJitterDoesNotDoubleCount() {
        // The smoother gives clean transitions, but make sure re-feeding the same
        // posture never increments twice.
        let sm = RakaatStateMachine()
        sm.update(posture: .standing, t: 0)
        sm.update(posture: .ruku, t: 2)
        sm.update(posture: .ruku, t: 2.1)
        sm.update(posture: .ruku, t: 2.2)
        XCTAssertEqual(sm.rakaatCount, 1)
    }
}

import XCTest
@testable import RakaatCore

final class ProximityRakaatCounterTests: XCTestCase {

    /// Helper: one sujud = cover at `start`, uncover after `held` seconds.
    private func sujud(_ c: ProximityRakaatCounter, start: Double, held: Double) {
        c.feed(covered: true, t: start)
        c.feed(covered: false, t: start + held)
    }

    func testTwoSujudIsOneRakaat() {
        let c = ProximityRakaatCounter(minSujudSeconds: 0.8)
        sujud(c, start: 0, held: 2)
        XCTAssertEqual(c.sujudCount, 1)
        XCTAssertEqual(c.rakaatCount, 1)   // mid-rakaat: first sujud done
        sujud(c, start: 5, held: 2)
        XCTAssertEqual(c.sujudCount, 2)
        XCTAssertEqual(c.rakaatCount, 1)   // rakaat 1 complete
    }

    func testFourSujudIsTwoRakaat() {
        let c = ProximityRakaatCounter(minSujudSeconds: 0.8)
        for i in 0..<4 { sujud(c, start: Double(i) * 5, held: 2) }
        XCTAssertEqual(c.sujudCount, 4)
        XCTAssertEqual(c.rakaatCount, 2)
    }

    func testBriefCoverIgnored() {
        let c = ProximityRakaatCounter(minSujudSeconds: 0.8)
        sujud(c, start: 0, held: 0.3)   // accidental tap, below threshold
        XCTAssertEqual(c.sujudCount, 0)
        XCTAssertEqual(c.rakaatCount, 0)
    }

    func testRepeatedCoveredEdgesDoNotDoubleCount() {
        let c = ProximityRakaatCounter(minSujudSeconds: 0.8)
        c.feed(covered: true, t: 0)
        c.feed(covered: true, t: 1)   // duplicate rising edge — keep earliest start
        c.feed(covered: false, t: 2)
        XCTAssertEqual(c.sujudCount, 1)
    }

    func testReset() {
        let c = ProximityRakaatCounter()
        sujud(c, start: 0, held: 2)
        c.reset()
        XCTAssertEqual(c.sujudCount, 0)
        XCTAssertEqual(c.rakaatCount, 0)
    }
}

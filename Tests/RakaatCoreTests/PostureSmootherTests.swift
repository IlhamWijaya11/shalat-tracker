import XCTest
@testable import RakaatCore

final class PostureSmootherTests: XCTestCase {
    func testHoldsUntilStable() {
        let s = PostureSmoother(holdFrames: 3)
        XCTAssertEqual(s.feed(.standing), .unknown)  // 1
        XCTAssertEqual(s.feed(.standing), .unknown)  // 2
        XCTAssertEqual(s.feed(.standing), .standing)  // 3 → commit
    }

    func testIgnoresSingleFrameJitter() {
        let s = PostureSmoother(holdFrames: 3)
        _ = s.feed(.standing); _ = s.feed(.standing); _ = s.feed(.standing)
        // A one-frame ruku blip must not flip the committed posture.
        XCTAssertEqual(s.feed(.ruku), .standing)
        XCTAssertEqual(s.feed(.standing), .standing)
    }
}

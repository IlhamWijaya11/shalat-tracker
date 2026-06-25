import XCTest
@testable import RakaatCore

final class PrayerTypeInferenceTests: XCTestCase {
    let infer = PrayerTypeInference()

    func testTwoRakaatIsSubuh() {
        XCTAssertEqual(infer.infer(rakaat: 2, minutesOfDay: 5 * 60), .subuh)
    }

    func testThreeRakaatIsMaghrib() {
        XCTAssertEqual(infer.infer(rakaat: 3, minutesOfDay: 18 * 60 + 30), .maghrib)
    }

    func testFourRakaatDisambiguatedByTime() {
        XCTAssertEqual(infer.infer(rakaat: 4, minutesOfDay: 13 * 60), .dzuhur)
        XCTAssertEqual(infer.infer(rakaat: 4, minutesOfDay: 16 * 60), .ashar)
        XCTAssertEqual(infer.infer(rakaat: 4, minutesOfDay: 20 * 60), .isya)
    }

    func testFourRakaatOutsideWindowIsUnknown() {
        // 4 rakaat at 3am matches no 4-rakaat window.
        XCTAssertEqual(infer.infer(rakaat: 4, minutesOfDay: 3 * 60), .unknown)
    }
}

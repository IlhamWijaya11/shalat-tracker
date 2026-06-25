// swift-tools-version:5.9
import PackageDescription

// RakaatCore = pure logic (no iOS deps) so it builds & tests on any platform
// (macOS/Linux/Windows). The iOS app target lives in `iOSApp/` and is added via
// an Xcode project on a Mac, importing this package as a local dependency.
let package = Package(
    name: "RakaatCore",
    products: [
        .library(name: "RakaatCore", targets: ["RakaatCore"]),
    ],
    targets: [
        .target(name: "RakaatCore"),
        .testTarget(name: "RakaatCoreTests", dependencies: ["RakaatCore"]),
    ]
)

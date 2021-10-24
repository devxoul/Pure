// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Pure",
  platforms: [
    .macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
  ],
  products: [.library(name: "Pure", targets: ["Pure"])],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0")),
  ],
  targets: [
    .target(name: "Pure", dependencies: []),
    .target(name: "PureStub", dependencies: ["Pure"]),
    .target(name: "TestSupport", dependencies: ["Pure"]),
    .testTarget(name: "PureTests", dependencies: ["Pure", "TestSupport", "Quick", "Nimble"]),
    .testTarget(name: "PureStubTests", dependencies: ["PureStub", "TestSupport", "Quick", "Nimble"]),
  ],
  swiftLanguageVersions: [.v5]
)

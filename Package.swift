// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Pure",
  products: [.library(name: "Pure", targets: ["Pure"])],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "1.2.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "7.0.3")),
  ],
  targets: [
    .target(name: "Pure", dependencies: []),
    .target(name: "PureStub", dependencies: ["Pure"]),
    .target(name: "TestSupport", dependencies: ["Pure"]),
    .testTarget(name: "PureTests", dependencies: ["Pure", "TestSupport", "Quick", "Nimble"]),
    .testTarget(name: "PureStubTests", dependencies: ["PureStub", "TestSupport", "Quick", "Nimble"]),
  ]
)

// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Pure",
  products: [.library(name: "Pure", targets: ["Pure"])],
  targets: [
    .target(name: "Pure", dependencies: []),
    .target(name: "PureStub", dependencies: ["Pure"]),
    .target(name: "Example", dependencies: ["Pure", "PureStub"]),
  ]
)

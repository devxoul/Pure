import XCTest
@testable import PureTests
@testable import PureStubTests

XCTMain([
    testCase(PureSpec.allTests),
    testCase(PureStubSpec.allTests),
])

project:
	bundle exec swiftproj generate-xcodeproj --enable-code-coverage
	bundle exec swiftproj add-system-framework --project Pure.xcodeproj --target QuickSpecBase --framework Platforms/iPhoneOS.platform/Developer/Library/Frameworks/XCTest.framework

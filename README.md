# Pure

![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/Pure.svg)](https://cocoapods.org/pods/Pure)
[![Build Status](https://travis-ci.org/devxoul/Pure.svg?branch=master)](https://travis-ci.org/devxoul/Pure)
[![Codecov](https://img.shields.io/codecov/c/github/devxoul/Pure.svg)](https://codecov.io/gh/devxoul/Pure)

Pure makes [Pure DI](http://blog.ploeh.dk/2014/06/10/pure-di/) easy in Swift. This repository also introduces a way to do Pure DI in a Swift application. Documentation is in progress.

## Background

### Pure DI

[Pure DI](http://blog.ploeh.dk/2014/06/10/pure-di/) is a way to do a dependency injection without a DI container. The term was introduced by [Mark Seemann](http://blog.ploeh.dk/). The core concept of Pure DI is not to use a DI container and to compose an entire object dependency graph in the [Composition Root](http://blog.ploeh.dk/2011/07/28/CompositionRoot/).

### Composition Root

In Cocoa applications, the entire object graph should be resolved in `AppDelegate`'s `application(_:didFinishLaunchingWithOptions:)` method. The `window` property and it's `rootViewController` property are the root dependencies. The best way to inject those dependencies is to create a struct named `AppDependency` and store the both dependencies in it.

```swift
struct AppDependency {
  let window: UIWindow
  let rootViewController: MyViewController
}

extension AppDependency {
  static func resolve() -> AppDependency {
    let otherDependency = OtherDependency()
    return AppDependency(
      window: UIWindow(frame: UIScreen.main.bounds),
      rootViewController: MyViewController(otherDependency: otherDependency)
    )
  }
}
```

It is important to separate a production environment from a testing environment. We use actual objects in the production environment and mock objects in the testing environment. In order to separate those environments from each other, we have to conditionally resolve the app dependency.

```swift
class AppDelegate {
  private var dependency: AppDependency!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // In testing environment, `self.dependency` is already set.
    self.dependency = self.dependency ?? AppDependency.resolve()
    self.window = self.dependency.window
    self.window?.rootViewController = self.dependency.rootViewController
  }
}

// Test
func setUp() {
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  let mockDependency = AppDependency(
    window: MockWindow(),
    rootViewController: MockViewController()
  )
  appDelegate?.dependency = mockDependency
}
```

### Problem

When it comes to a Cocoa application, there is a problem: almost every view controllers are constructed lazily. For example, `DetailViewController` not created until an user taps an item on `ListViewController`. So we have to pass a factory 

## License

Pure is under MIT license. See the [LICENSE](LICENSE) file for more info.

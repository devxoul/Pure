# Pure

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/Pure.svg)](https://cocoapods.org/pods/Pure)
[![Build Status](https://github.com/devxoul/Pure/workflows/CI/badge.svg)](https://github.com/devxoul/Pure/actions)
[![Codecov](https://img.shields.io/codecov/c/github/devxoul/Pure.svg)](https://codecov.io/gh/devxoul/Pure)

Pure makes [Pure DI](http://blog.ploeh.dk/2014/06/10/pure-di/) easy in Swift. This repository also introduces a way to do Pure DI in a Swift application.

## Table of Contents

* [Background](#background)
    * [Pure DI](#pure-di)
    * [Composition Root](#composition-root)
        * [AppDependency](#appdependency)
        * [Testing AppDelegate](#testing-appdelegate)
        * [Separating AppDelegate](#separating-appdelegate)
    * [Lazy Dependency](#lazy-dependency)
        * [Using Factory](#using-factory)
        * [Using Configurator](#using-configurator)
    * [Problem](#problem)
* [Getting Started](#getting-started)
    * [Depenency and Payload](#dependency-and-payload)
    * [Module](#module)
        * [Factory Module](#factory-module)
        * [Configurator Module](#configurator-module)
    * [Customizing](#customizing)
        *  [Storyboard Support](#storyboard-support)
        *  [URLNavigator Support](#urlnavigator-support)
* [Installation](#installation)
* [Contributing](#contribution)
* [License](#license)

## Background

### Pure DI

[Pure DI](http://blog.ploeh.dk/2014/06/10/pure-di/) is a way to do a dependency injection without a DI container. The term was first introduced by [Mark Seemann](http://blog.ploeh.dk/). The core concept of Pure DI is not to use a DI container and to compose an entire object dependency graph in the [Composition Root](http://blog.ploeh.dk/2011/07/28/CompositionRoot/).

### Composition Root

The Composion Root is where the entire object graph is resolved. In a Cocoa application, `AppDelegate` is the Composition Root.

#### AppDependency

The root dependencies are the app delegate's dependency and the root view controller's dependency. The best way to inject those dependencies is to create a struct named `AppDependency` and store both dependencies in it.

```swift
struct AppDependency {
  let networking: Networking
  let remoteNotificationService: RemoteNotificationService
}

extension AppDependency {
  static func resolve() -> AppDependency {
    let networking = Networking()
    let remoteNotificationService = RemoteNotificationService()

    return AppDependency(
      networking: networking
      remoteNotificationService: remoteNotificationService
    )
  }
}
```

It is important to separate a production environment from a testing environment. We have to use an actual object in a production environment and a mock object in a testing environment.

AppDelegate is created automatically by the system using `init()`. In this initializer we're going to initialize the actaul app dependency with `AppDependency.resolve()`. On the other hand, we're going to provide a `init(dependency:)` to inject a mock app dependency in a testing environment.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
  private let dependency: AppDependency

  /// Called from the system (it's private: not accessible in the testing environment)
  private override init() {
    self.dependency = AppDependency.resolve()
    super.init()
  }

  /// Called in a testing environment
  init(dependency: AppDependency) {
    self.dependency = dependency
    super.init()
  }
}
```

The app dependency can be used as the code below:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
  // inject rootViewController's dependency
  if let viewController = self.window?.rootViewController as? RootViewController {
    viewController.networking = self.dependency.networking
  }
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  // delegates remote notification receive event
  self.dependency.remoteNotificationService.receiveRemoteNotification(userInfo)
}
```

#### Testing AppDelegate

`AppDelegate` is one of the most important class in a Cocoa application. It resolves an app dependency and handles app events. It can be easily tested as we separated the app dependency.

This is an example test case of `AppDelegate`. It verifies that `AppDelegate` correctly injects root view controller's dependency in `application(_:didFinishLaunchingWithOptions)`.

```swift
class AppDelegateTests: XCTestCase {
  func testInjectRootViewControllerDependencies() {
    // given
    let networking = MockNetworking()
    let mockDependency = AppDependency(
      networking: networking,
      remoteNotificationService: MockRemoteNotificationService()
    )
    let appDelegate = AppDelegate(dependency: mockDependency)
    appDelegate.window = UIWindow()
    appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

    // when
    _ = appDelegate.application(.shared, didFinishLaunchingWithOptions: nil)

    // then
    let rootViewController = appDelegate.window?.rootViewController as? RootViewController
    XCTAssertTrue(rootViewController?.networking === networking)
  }
}
```

You can write tests for verifying remote notification events, open url events and even an app termination event.

#### Separating AppDelegate

But there is a problem: `AppDelegate` is still created by the system while testing. It causes `AppDependency.resolve()` gets called so we have to use a fake app delegate class in a testing environment.

First of all, create a new file in the test target. Define a new class named `TestAppDelegate` and implement basic requirements of the delegate protocol.

```swift
// iOS
class TestAppDelegate: NSObject, UIApplicationDelegate {
  var window: UIWindow?
}

// macOS
class TestAppDelegate: NSObject, NSApplicationDelegate {
}
```

Then create another file named **`main.swift`** to your application target. This file will replace the entry point of the application. We are going to provide different app delegates in this file. Don't forget to replace `"MyAppTests.TestAppDelegate"` with your project target and class name.

```swift
// iOS
UIApplicationMain(
  CommandLine.argc,
  CommandLine.unsafeArgv,
  NSStringFromClass(UIApplication.self),
  NSStringFromClass(NSClassFromString("MyAppTests.TestAppDelegate") ?? AppDelegate.self)
)

// macOS
func createAppDelegate() -> NSApplicationDelegate {
  if let cls = NSClassFromString("AllkdicTests.TestAppDelegate") as? (NSObject & NSApplicationDelegate).Type {
    return cls.init()
  } else {
    return AppDelegate(dependency: AppDependency.resolve())
  }
}

let application = NSApplication.shared
application.delegate = createAppDelegate()
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
```

Finally, remove the `@UIApplicationMain` and `@NSApplicationMain` from the `AppDelegate`.

```diff
  // iOS
- @UIApplicationMain
  class AppDelegate: UIResponder, UIApplicationDelegate

  // macOS
- @NSApplicationMain
  class AppDelegate: NSObject, NSApplicationDelegate
```

It is also a good practice to add a test case to verify that the application is using `TestAppDelegate` in a testing environment.

```swift
XCTAssertTrue(UIApplication.shared.delegate is TestAppDelegate)
```

### Lazy Dependency

#### Using Factory

In Cocoa applications, view controllers are created lazily. For example, `DetailViewController` is not created until the user taps an item on `ListViewController`. In this case we have to pass a factory closure of `DetailViewController` to `ListViewController`.

```swift
/// A root view controller
class ListViewController {
  var detailViewControllerFactory: ((Item) -> DetailViewController)!

  func presentItemDetail(_ selectedItem: Item) {
    let detailViewController = self.detailViewControllerFactory(selectedItem)
    self.present(detailViewController, animated: true)
  }
}

static func resolve() -> AppDependency {
  let storyboard = UIStoryboard(name: "Main", bundle: nil)
  let networking = Networking()

  let detailViewControllerFactory: (Item) -> DetailViewController = { selectedItem in
    let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    detailViewController.networking = networking
    detailViewController.item = selectedItem
    return detailViewController
  }

  return AppDependency(
    networking: networking,
    detailViewControllerFactory: detailViewControllerFactory
  )
}
```

But it has a critical problem: we cannot test the factory closure. Because the factory closure is created in the Composition Root but we should not access the Composition Root in a testing environment. What if I forget to inject the `DetailViewController.networking` property?

One possible approach is to create a factory closure outside of the Composition Root. Note that `Storyboard` and `Networking` is from the Composition Root, and `Item` is from the previous view controller so we have to separate the scope.

```swift
extension DetailViewController {
  static let factory: (UIStoryboard, Networking) -> (Item) -> DetailViewController = { storyboard, networking in
    return { selectedItem in
      let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
      detailViewController.networking = networking
      detailViewController.item = selectedItem
      return detailViewController
    }
  }
}

static func resolve() -> AppDependency {
  let storyboard = ...
  let networking = ...
  return .init(
    detailViewControllerFactory: DetailViewController.factory(storyboard, networking)
  )
}
```

Now we can test the `DetailViewController.factory` closure. Every dependencies are resolved in the Composition Root and a selected item can be passed from `ListViewController` to `DetailViewController` in runtime.

#### Using Configurator

There is another lazy dependency. Cells are created lazily but we cannot use the factory closure because the cells are created by the framework. We can just configure the cells.

Imagine that an `UICollectionViewCell` or `UITableViewCell` displays an image. There is an `imageDownloader` which downloads an actual image in a production environment and returns a mock image in a testing environment.

```swift
class ItemCell {
  var imageDownloader: ImageDownloaderType?
  var imageURL: URL? {
    didSet {
      guard let imageDownloader = self.imageDownloader else { return }
      self.imageView.setImage(with: self.imageURL, using: imageDownloader)
    }
  }
}
```

This cell is displayed in `DetailViewController `. `DetailViewController` should inject `imageDownloader` to the cell and sets the `image` property. Like we did in the factory, we can create a configurator closure for it. But this closure takes an existing instance and doens't have a return value.

```swift
class ItemCell {
  static let configurator: (ImageDownloaderType) -> (ItemCell, UIImage) -> Void = { imageDownloader
    return { cell, image in
      cell.imageDownloader = imageDownloader
      cell.image = image
    }
  }
}
```

`DetailViewController` can have the configurator and use it when configurating cell.

```swift
class DetailViewController {
  var itemCellConfigurator: ((ItemCell, UIImage) -> Void)?

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    ...
    self.itemCellConfigurator?(cell, image)
    return cell
  }
}
```

`DetailViewController.itemCellConfigurator` is injected from a factory.

```swift
extension DetailViewController {
  static let factory: (UIStoryboard, Networking, (ItemCell, UIImage) -> Void) -> (Item) -> DetailViewController = { storyboard, networking, imageCellConfigurator in
    return { selectedItem in
      let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
      detailViewController.networking = networking
      detailViewController.item = selectedItem
      detailViewController.imageCellConfigurator = imageCellConfigurator
      return detailViewController
    }
  }
}
```

And the Composition Root finally looks like:

```swift
static func resolve() -> AppDependency {
  let storybard = ...
  let networking = ...
  let imageDownloader = ...
  let listViewController = ...
  listViewController.detailViewControllerFactory = DetailViewController.factory(
    storyboard,
    networking,
    ImageCell.configurator(imageDownloader)
  )
  ...
}
```

### Problem

Theoretically it works. But as you can see in the `DetailViewController.factory` it will be very complicated when there are many dependencies. This is why I created Pure. Pure makes factories and configurators neat.

## Getting Started

### Dependency and Payload

First of all, take a look at the factory and the configurator we used in the example code.

```swift
static let factory: (UIStoryboard, Networking, (ItemCell, UIImage) -> Void) -> (Item) -> DetailViewController
static let configurator: (ImageDownloaderType) -> (ItemCell, UIImage) -> Void
```

Those are the functions that return another function. The outer functions are executed in the Composition Root to inject static dependencies like `Networking` and the inner functions are executed in the view controllers to pass a runtime information like `selectedItem`. The parameter of the outer function is *Dependency*. The parameter of the inner function is *Payload*.

```
static let factory: (UIStoryboard, Networking, (ItemCell, UIImage) -> Void) -> (Item) -> DetailViewController
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^      ^^^^
                                        Dependency                             Payload

static let configurator: (ImageDownloaderType) -> (ItemCell, UIImage) -> Void
                          ^^^^^^^^^^^^^^^^^^^      ^^^^^^^^^^^^^^^^^
                              Dependency                Payload
```

Pure generalizes the factory and configurator using Dependency and Payload.

### Module

Pure treats every class that requires a dependency and a payload as a *Module*. A protocol `Module` requires two types: `Dependency` and `Payload`.

```swift
protocol Module {
  /// A dependency that is resolved in the Composition Root.
  associatedtype Dependency

  /// A runtime information for configuring the module.
  associatedtype Payload
}
```

There are two types of module: `FactoryModule` and `ConfiguratorModule`.

#### Factory Module

FactoryModule is a generalized version of factory closure. It requires an initializer which takes both `dependency` and `payload`.

```swift
protocol FactoryModule: Module {
  init(dependency: Dependency, payload: Payload)
}

class DetailViewController: FactoryModule {
  struct Dependency {
    let storyboard: UIStoryboard
    let networking: Networking
  }

  struct Payload {
    let selectedItem: Item
  }

  init(dependency: Dependency, payload: Payload) {
  }
}
```

When a class conforms to `FactoryModule`, it will have a nested type `Factory`. `Factory.init(dependency:)` takes a dependency of the module and has a method `create(payload:)` which creates a new instance.

```swift
class Factory<Module> {
  let dependency: Module.Dependency
  func create(payload: Module.Payload) -> Module
}

// In AppDependency
let factory = DetailViewController.Factory(dependency: .init(
  storyboard: storyboard
  networking: networking
))

// In ListViewController
let viewController = factory.create(payload: .init(
  selectedItem: selectedItem
))
```

#### Configurator Module

ConfiguratorModule is a generalized version of configurator closure. It requires a `configure()` method which takes both `dependency` and `payload`.

```swift
protocol ConfiguratorModule: Module {
  func configure(dependency: Dependency, payload: Payload)
}

class ItemCell: ConfiguratorModule {
  struct Dependency {
    let imageDownloader: ImageDownloaderType
  }

  struct Payload {
    let image: UIImage
  }

  func configure(dependency: Dependency, payload: Payload) {
    self.imageDownloader = dependency.imageDownloader
    self.image = payload.image
  }
}
```

When a class conforms to `ConfiguratorModule`, it will have a nested type `Configurator`. `Configurator.init(dependency:)` takes a dependency of the module and has a method `configure(_:payload:)` which configures an existing instance.

```swift
class Configurator<Module> {
  let dependency: Module.Dependency
  func configure(_ module: Module, payload: Module.Payload)
}

// In AppDependency
let configurator = ItemCell.Configurator(dependency: .init(
  imageDownloader: imageDownloader
))

// In DetailViewController
configurator.configure(cell, payload: .init(image: image))
```

With `FactoryModule` and `ConfiguratorModule`, the example can be refactored as below:

```swift
static func resolve() -> AppDependency {
  let storybard = ...
  let networking = ...
  let imageDownloader = ...
  return .init(
    detailViewControllerFactory: DetailViewController.Factory(dependency: .init(
      storyboard: storyboard,
      networking: networking,
      itemCellConfigurator: ItemCell.Configurator(dependency: .init(
        imageDownloader: imageDownloader
      ))
    ))
  )
}
```

### Customizing

`Factory` and `Configurator` are customizable. This is an example of customized factory:

```swift
extension Factory where Module == DetailViewController {
  func create(payload: Module.Payload, extraValue: ExtraValue) -> Payload {
    let module = self.create(payload: payload)
    module.extraValue = extraValue
    return module
  }
}
```

#### Storyboard Support

`FactoryModule` can support Storyboard-instantiated view controllers using customizing feature. The code below is an example for storyboard support of `DetailViewController`:

```swift
extension Factory where Module == DetailViewController {
  func create(payload: Module.Payload) -> Payload {
    let module = self.dependency.storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! Module
    module.networking = dependency.networking
    module.itemCellConfigurator = dependency.itemCellConfigurator
    module.selectedItem = payload.selectedItem
    return module
  }
}
```

#### URLNavigator Support

[URLNavigator](https://github.com/devxoul/URLNavigator) is an elegant library for deeplink support. Pure can be also used in registering a view controller to a navigator.

```swift
class UserViewController {
  struct Payload {
    let userID: Int
  }
}

extension Factory where Module == UserViewController {
  func create(url: URLConvertible, values: [String: Any], context: Any?) -> Module? {
    guard let userID = values["id"] else { return nil }
    return self.create(payload: .init(userID: userID))
  }
}

let navigator = Navigator()
navigator.register("myapp://user/<id>", UserViewController.Factory().create)
```

## Installation

* **Using [CocoaPods](https://cocoapods.org)**:

    ```ruby
    pod 'Pure'
    ```

* [Carthage](https://github.com/Carthage/Carthage) is not yet supported.

## Contribution

Any discussions and pull requests are welcomed 💖

* To development:

    ```console
    $ make project
    ```

* To test:

    ```console
    $ swift test
    ```

## License

Pure is under MIT license. See the [LICENSE](LICENSE) file for more info.

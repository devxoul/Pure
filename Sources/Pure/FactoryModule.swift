/// A module that can be constructed with a factory.
public protocol FactoryModule: Module {

  /// A factory for `Self`.
  associatedtype Factory = Pure.Factory<Self>

  /// Creates an instance of a module with a dependency and a payload.
  init(dependency: Dependency, payload: Payload)
}

public extension FactoryModule where Dependency == Void {
  /// Creates an instance of a module with a payload.
  init(payload: Payload) {
    self.init(dependency: Void(), payload: payload)
  }
}

public extension FactoryModule where Payload == Void {
  /// Creates an instance of a module with a dependency.
  init(dependency: Dependency) {
    self.init(dependency: dependency, payload: Void())
  }
}

public extension FactoryModule where Dependency == Void, Payload == Void {
  /// Creates an instance of a module.
  init() {
    self.init(dependency: Void(), payload: Void())
  }
}

#if os(iOS) || os(tvOS)
import UIKit

public extension FactoryModule where Self: UIViewController {
  init(dependency: Dependency, payload: Payload) {
    self.init(nibName: nil, bundle: nil)
  }
}
#endif

#if os(macOS)
import AppKit

public extension FactoryModule where Self: NSViewController {
  init(dependency: Dependency, payload: Payload) {
    self.init(nibName: nil, bundle: nil)
  }
}
#endif

import Foundation

/// A generic configurator. It is constructed with a static dependency and configures an existing
/// module instance with a runtime parameter.
open class Configurator<Module: ConfiguratorModule> {
  private let lock = NSLock()

  private let dependencyClosure: () -> Module.Dependency
  private var cachedDependency: Module.Dependency?

  /// A static dependency of a module.
  open var dependency: Module.Dependency {
    self.lock.lock()
    defer { self.lock.unlock() }

    if let dependency = self.cachedDependency {
      return dependency
    }

    let dependency = self.dependencyClosure()
    self.cachedDependency = dependency
    return dependency
  }

  /// Creates an instance of `Configurator`.
  ///
  /// - parameter dependency: A static dependency which should be resolved in a composition root.
  public init(dependency: @autoclosure @escaping () -> Module.Dependency) {
    self.dependencyClosure = dependency
  }

  /// Configures an existing module instance with a runtime parameter.
  ///
  /// - parameter module: An instance of a module to be configured.
  /// - parameter payload: A runtime parameter which is required to configure a module.
  open func configure(_ module: Module, payload: Module.Payload) {
    module.configure(dependency: self.dependency, payload: payload)
  }
}

public extension Configurator where Module.Payload == Void {
  /// Configures an existing module instance with a runtime parameter.
  ///
  /// - parameter module: An instance of a module to be configured.
  func configure(_ module: Module) {
    self.configure(module, payload: Void())
  }
}

public extension Configurator where Module.Dependency == Void {
  /// Creates an instance of `Configurator`.
  convenience init() {
    self.init(dependency: Void())
  }
}

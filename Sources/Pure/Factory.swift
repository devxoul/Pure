/// A generic factory. It is constructed with a static dependency and creates a module instance
/// with a runtime parameter.
public struct Factory<Module: FactoryModule> {

  /// A static dependency of a module.
  public let dependency: () -> Module.Dependency

  /// Creates an instance of `Factory`.
  ///
  /// - parameter dependency: A static dependency which should be resolved in a composition root.
  public init(dependency: @autoclosure @escaping () -> Module.Dependency) {
    self.dependency = dependency
  }

  /// Creates an instance of a module with a runtime parameter.
  ///
  /// - parameter payload: A runtime parameter which is required to construct a module.
  public func create(payload: Module.Payload) -> Module {
    return Module.init(dependency: self.dependency(), payload: payload)
  }
}

public extension Factory where Module.Dependency == Void {
  public init() {
    self.init(dependency: Void())
  }
}

public extension Factory where Module.Payload == Void {
  public func create() -> Module {
    return Module.init(dependency: self.dependency(), payload: Void())
  }
}

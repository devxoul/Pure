/// A generic configurator. It is constructed with a static dependency and configures an existing
/// module instance with a runtime parameter.
public struct Configurator<Module: ConfiguratorModule> {

  /// A static dependency of a module.
  private let dependency: () -> Module.Dependency

  /// Creates an instance of `Configurator`.
  ///
  /// - parameter dependency: A static dependency which should be resolved in a composition root.
  public init(dependency: @autoclosure @escaping () -> Module.Dependency) {
    self.dependency = dependency
  }

  /// Configures an existing module instance with a runtime parameter.
  ///
  /// - parameter module: An instance of a module to be configured.
  /// - parameter payload: A runtime parameter which is required to configure a module.
  public func configure(_ module: Module, payload: Module.Payload) {
    module.configure(dependency: self.dependency(), payload: payload)
  }
}

public extension Configurator where Module.Dependency == Void {
  public init() {
    self.init(dependency: Void())
  }
}

public extension Configurator where Module.Payload == Void {
  public func configure(_ module: Module) {
    module.configure(dependency: self.dependency(), payload: Void())
  }
}

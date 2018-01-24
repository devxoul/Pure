/// A generic configurator. It is constructed with a static dependency and configures an existing
/// module instance with a runtime parameter.
public class Configurator<Module: ConfiguratorModule> {
  private let dependencyClosure: () -> Module.Dependency

  /// A static dependency of a module.
  public var dependency: Module.Dependency {
    return self.dependencyClosure()
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
  public func configure(_ module: Module, payload: Module.Payload) {
    module.configure(dependency: self.dependency, payload: payload)
  }
}

public extension Configurator where Module.Dependency == Void {
  public convenience init() {
    self.init(dependency: Void())
  }
}

public extension Configurator where Module.Payload == Void {
  public func configure(_ module: Module) {
    module.configure(dependency: self.dependency, payload: Void())
  }
}


// MARK: Test Support

public extension Configurator {
  public static func stub(_ closure: @escaping StubConfigurator<Module>.Closure = { _, _ in }) -> StubConfigurator<Module> {
    return StubConfigurator(closure: closure)
  }
}

public final class StubConfigurator<Module: ConfiguratorModule>: Configurator<Module> {
  public typealias Closure = (Module, Module.Payload) -> Void

  private let closure: Closure

  @available(*, unavailable)
  public override var dependency: Module.Dependency {
    return super.dependency
  }

  fileprivate init(closure: @escaping Closure) {
    self.closure = closure
    super.init(dependency: nil as Module.Dependency!)
  }

  override public func configure(_ module: Module, payload: Module.Payload) {
    self.closure(module, payload)
  }
}

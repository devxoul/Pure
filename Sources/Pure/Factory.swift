/// A generic factory. It is constructed with a static dependency and creates a module instance
/// with a runtime parameter.
public class Factory<Module: FactoryModule> {
  private let dependencyClosure: () -> Module.Dependency

  /// A static dependency of a module.
  public var dependency: Module.Dependency {
    return self.dependencyClosure()
  }

  /// Creates an instance of `Factory`.
  ///
  /// - parameter dependency: A static dependency which should be resolved in a composition root.
  public init(dependency: @autoclosure @escaping () -> Module.Dependency) {
    self.dependencyClosure = dependency
  }

  /// Creates an instance of a module with a runtime parameter.
  ///
  /// - parameter payload: A runtime parameter which is required to construct a module.
  public func create(payload: Module.Payload) -> Module {
    return Module.init(dependency: self.dependency, payload: payload)
  }
}

public extension Factory where Module.Dependency == Void {
  /// Creates an instance of `Factory`.
  public convenience init() {
    self.init(dependency: Void())
  }
}

public extension Factory where Module.Payload == Void {
  /// Creates an instance of a module.
  public func create() -> Module {
    return Module.init(dependency: self.dependency, payload: Void())
  }
}


// MARK: - Test Support

public extension Factory {
  public static func stub(_ closure: @autoclosure @escaping () -> Module? = nil) -> StubFactory<Module> {
    return StubFactory(closure: closure)
  }
}

public class StubFactory<Module: FactoryModule>: Factory<Module> {
  private let closure: () -> Module?

  @available(*, unavailable)
  public override var dependency: Module.Dependency {
    return super.dependency
  }

  fileprivate init(closure: @escaping () -> Module?) {
    self.closure = closure
    super.init(dependency: nil as Module.Dependency!)
  }

  override public func create(payload: Module.Payload) -> Module {
    return self.closure() as Module!
  }
}

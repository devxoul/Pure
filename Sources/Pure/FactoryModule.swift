/// A module that can be constructed with a factory.
public protocol FactoryModule: Module {

  /// A factory for `Self`.
  associatedtype Factory = Pure.Factory<Self>

  /// Creates an instance of a module with a dependency and a payload.
  init(dependency: Dependency, payload: Payload)
}

public extension FactoryModule where Dependency == Void {
  public init(payload: Payload) {
    self.init(dependency: Void(), payload: payload)
  }
}

public extension FactoryModule where Payload == Void {
  public init(dependency: Dependency) {
    self.init(dependency: dependency, payload: Void())
  }
}

public extension FactoryModule where Dependency == Void, Payload == Void {
  public init() {
    self.init(dependency: Void(), payload: Void())
  }
}

/// A module that can be constructed with a factory.
public protocol FactoryModule: Module {

  /// A factory for `Self`.
  associatedtype Factory = Pure.Factory<Self>

  /// Creates an instance of a module with a dependency and a payload.
  init(dependency: Dependency, payload: Payload)
}

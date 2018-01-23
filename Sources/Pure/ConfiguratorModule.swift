/// A module that can be configurated with an existing instance.
public protocol ConfiguratorModule: class, Module {

  /// A configurator for `Self`.
  associatedtype Configurator = Pure.Configurator<Self>

  /// Configures an existing module with a dependency and a payload.
  func configure(dependency: Dependency, payload: Payload)
}

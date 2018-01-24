#if !COCOAPODS
import Pure
#endif

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

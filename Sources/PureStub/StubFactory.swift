#if !COCOAPODS
import Pure
#endif

public extension Factory {
  public static func stub(
    _ closure: @escaping (Module.Payload) -> Module?
  ) -> StubFactory<Module> {
    return StubFactory(closure: closure)
  }

  public static func stub(
    _ instance: @autoclosure @escaping () -> Module? = nil
  ) -> StubFactory<Module> {
    return StubFactory(closure: { _ in instance() })
  }
}

public final class StubFactory<Module: FactoryModule>: Factory<Module> {
  private let closure: (Module.Payload) -> Module?

  @available(*, unavailable)
  public override var dependency: Module.Dependency {
    return super.dependency
  }

  fileprivate init(closure: @escaping (Module.Payload) -> Module?) {
    self.closure = closure
    super.init(dependency: nil as Module.Dependency!)
  }

  override public func create(payload: Module.Payload) -> Module {
    return self.closure(payload) as Module!
  }
}

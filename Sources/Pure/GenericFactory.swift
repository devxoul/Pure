import Foundation

/// A factory that allows to create an instance with a protocol.
public struct GenericFactory<ModuleType, PayloadType> {
  public typealias Module = ModuleType
  public typealias Payload = PayloadType

  private let closure: (Payload) -> Module

  public init<Dependency>(_ closure: @escaping (Dependency, Payload) -> Module, dependency dependencyClosure: @autoclosure @escaping () -> Dependency) {
    let lock = NSLock()

    var cachedDependency: Dependency?
    var dependency: Dependency {
      lock.lock()
      defer { lock.unlock() }

      if let dependency = cachedDependency {
        return dependency
      }

      let dependency = dependencyClosure()
      cachedDependency = dependency
      return dependency
    }

    self.closure = { payload in closure(dependency, payload) }
  }

  public func create(payload: Payload) -> Module {
    return self.closure(payload)
  }
}

public extension GenericFactory where Payload == Void {
  /// Creates an instance of a module.
  func create() -> Module {
    return self.create(payload: Void())
  }
}

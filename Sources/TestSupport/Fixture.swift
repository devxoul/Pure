import Pure

struct SharedDependency {
  let networking: String
  init(networking: String) {
    self.networking = networking
  }
}

struct Payload {
  let id: Int
  init(id: Int) {
    self.id = id
  }
}

class FactoryFixture<DependencyType, PayloadType>: FactoryModule {
  typealias Dependency = DependencyType
  typealias Payload = PayloadType

  let dependency: Dependency
  let payload: Payload

  required init(dependency: Dependency, payload: Payload) {
    self.dependency = dependency
    self.payload = payload
  }
}

class ConfiguratorFixture<DependencyType, PayloadType>: ConfiguratorModule {
  typealias Dependency = DependencyType
  typealias Payload = PayloadType

  var dependency: Dependency?
  var payload: Payload?

  func configure(dependency: Dependency, payload: Payload) {
    self.dependency = dependency
    self.payload = payload
  }
}

#if os(iOS) || os(tvOS)
import UIKit

class ViewControllerFixture: UIViewController, FactoryModule {
  typealias Dependency = String
  typealias Payload = String
}
#endif

#if os(macOS)
import AppKit

class ViewControllerFixture: NSViewController, FactoryModule {
  typealias Dependency = String
  typealias Payload = String
}
#endif

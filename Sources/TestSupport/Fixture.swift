import Pure

struct SharedDependency {
  let networking: String
  init(networking: String) {
    self.networking = networking
  }
}

struct SharedPayload {
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


protocol GenericFactoryFixtureProtocol {
  typealias Factory = GenericFactory<GenericFactoryFixtureProtocol, Payload>
  typealias Payload = (id: Int, username: String)

  var networking: String { get }
  var id: Int { get }
  var username: String { get }
}

class GenericFactoryFixture: GenericFactoryFixtureProtocol {
  typealias Dependency = SharedDependency

  let networking: String
  let id: Int
  let username: String

  init(dependency: Dependency, payload: Payload) {
    self.networking = dependency.networking
    self.id = payload.id
    self.username = payload.username
  }
}

protocol GenericFactoryNoPayloadFixtureProtocol {
  typealias Factory = GenericFactory<GenericFactoryNoPayloadFixtureProtocol, Payload>
  typealias Payload = Void

  var networking: String { get }
}

class GenericFactoryNoPayloadFixture: GenericFactoryNoPayloadFixtureProtocol {
  typealias Dependency = SharedDependency

  let networking: String

  init(dependency: Dependency, payload: Payload) {
    self.networking = dependency.networking
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

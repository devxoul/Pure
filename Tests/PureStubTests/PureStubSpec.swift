import Foundation
import Nimble
import Quick
@testable import Pure
@testable import PureStub
@testable import TestSupport

final class PureStubSpec: QuickSpec {
  override func spec() {
    describe("StubFactory.create(_ closure:)") {
      it("returns a stubbed instance") {
        let factory: FactoryFixture<SharedDependency, Payload>.Factory = .stub { payload in
          FactoryFixture<SharedDependency, Payload>(
            dependency: .init(networking: "Networking A"),
            payload: payload
          )
        }
        let instance = factory.create(payload: .init(id: 200))
        expect(instance.dependency.networking) == "Networking A"
        expect(instance.payload.id) == 200
      }

      it("returns a stubbed instance with Void payload") {
        let factory: FactoryFixture<SharedDependency, Void>.Factory = .stub { payload in
          FactoryFixture<SharedDependency, Void>(
            dependency: .init(networking: "Networking A"),
            payload: payload
          )
        }
        let instance = factory.create()
        expect(instance.dependency.networking) == "Networking A"
      }
    }

    describe("StubFactory.create(_ instance:)") {
      it("returns a stubbed instance") {
        let instance1 = FactoryFixture<SharedDependency, Payload>(
          dependency: .init(networking: "Networking A"),
          payload: .init(id: 100)
        )
        let factory: FactoryFixture<SharedDependency, Payload>.Factory = .stub(instance1)
        let instance2 = factory.create(payload: .init(id: 200))
        expect(instance1) === instance2
        expect(instance2.dependency.networking) == "Networking A"
        expect(instance2.payload.id) == 100
      }

      it("returns a stubbed instance with Void payload") {
        let instance1 = FactoryFixture<SharedDependency, Void>(
          dependency: .init(networking: "Networking A"),
          payload: Void()
        )
        let factory: FactoryFixture<SharedDependency, Void>.Factory = .stub(instance1)
        let instance2 = factory.create()
        expect(instance1) === instance2
        expect(instance2.dependency.networking) == "Networking A"
      }
    }

    describe("StubConfigurator.create()") {
      it("doesn't configure an instance without a closure parameter") {
        let instance = ConfiguratorFixture<SharedDependency, Payload>()
        let configurator: ConfiguratorFixture<SharedDependency, Payload>.Configurator = .stub()
        configurator.configure(instance, payload: .init(id: 100))
        expect(instance.dependency).to(beNil())
        expect(instance.payload).to(beNil())
      }

      it("configures an instance with a closure parameter") {
        let instance = ConfiguratorFixture<SharedDependency, Payload>()
        let configurator: ConfiguratorFixture<SharedDependency, Payload>.Configurator = .stub() { module, _ in
          module.dependency = .init(networking: "Networking B")
          module.payload = .init(id: 200)
        }
        configurator.configure(instance, payload: .init(id: 100))
        expect(instance.dependency?.networking) == "Networking B"
        expect(instance.payload?.id) == 200
      }
    }
  }
}

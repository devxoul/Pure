import Nimble
import Quick
@testable import Pure
@testable import PureStub
@testable import TestSupport

final class PureStubSpec: QuickSpec {
  override func spec() {
    describe("StubFactory.create(_ closure:)") {
      it("returns a stubbed instance") {
        let factory: FactoryFixture<Dependency, Payload>.Factory = .stub { payload in
          FactoryFixture<Dependency, Payload>(
            dependency: .init(networking: "Networking A"),
            payload: payload
          )
        }
        let instance = factory.create(payload: .init(id: 200))
        expect(instance.dependency.networking) == "Networking A"
        expect(instance.payload.id) == 200
      }
    }

    describe("StubFactory.create(_ instance:)") {
      it("returns a stubbed instance") {
        let instance1 = FactoryFixture<Dependency, Payload>(
          dependency: .init(networking: "Networking A"),
          payload: .init(id: 100)
        )
        let factory: FactoryFixture<Dependency, Payload>.Factory = .stub(instance1)
        let instance2 = factory.create(payload: .init(id: 200))
        expect(instance1) === instance2
        expect(instance2.dependency.networking) == "Networking A"
        expect(instance2.payload.id) == 100
      }
    }

    describe("StubConfigurator.create()") {
      it("doesn't configure an instance without a closure parameter") {
        let instance = ConfiguratorFixture<Dependency, Payload>()
        let configurator: ConfiguratorFixture<Dependency, Payload>.Configurator = .stub()
        configurator.configure(instance, payload: .init(id: 100))
        expect(instance.dependency).to(beNil())
        expect(instance.payload).to(beNil())
      }

      it("configures an instance with a closure parameter") {
        let instance = ConfiguratorFixture<Dependency, Payload>()
        let configurator: ConfiguratorFixture<Dependency, Payload>.Configurator = .stub() { module, _ in
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

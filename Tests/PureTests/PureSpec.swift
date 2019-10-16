#if os(iOS) || os(tvOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif
import Nimble
import Quick
import XCTest
@testable import Pure
@testable import TestSupport

final class PureSpec: QuickSpec {
  override func spec() {
    describe("a factory module") {
      it("creates an instance with a dependency and a payload") {
        let instance = FactoryFixture<Dependency, Payload>(
          dependency: .init(networking: "Networking A"),
          payload: .init(id: 100)
        )
        expect(instance.dependency.networking) == "Networking A"
        expect(instance.payload.id) == 100
      }

      it("creates an instance with a dependency when the module doesn't require a payload") {
        let instance = FactoryFixture<Dependency, Void>(
          dependency: .init(networking: "Networking B")
        )
        expect(instance.dependency.networking) == "Networking B"
        expect(instance.payload) == Void()
      }

      it("creates an instance with a payload when the module doesn't require a dependency") {
        let instance = FactoryFixture<Void, Payload>(
          payload: .init(id: 200)
        )
        expect(instance.dependency) == Void()
        expect(instance.payload.id) == 200
      }

      it("creates an instance when the module doesn't require a dependency and a payload") {
        let instance = FactoryFixture<Void, Void>()
        expect(instance.dependency) == Void()
        expect(instance.payload) == Void()
      }

      #if os(iOS) || os(tvOS) || os(macOS)
      context("when it is a view controller") {
        it("doesn't require init(dependency:payload:)") {
          let viewController = ViewControllerFixture(dependency: "Dependency", payload: "Payload")
          expect(viewController).toNot(beNil())
        }
      }
      #endif
    }

    describe("a configurator module") {
      it("configures an instance with a dependency and a payload") {
        let instance = ConfiguratorFixture<Dependency, Payload>()
        instance.configure(dependency: .init(networking: "Networking A"), payload: .init(id: 100))
        expect(instance.dependency?.networking) == "Networking A"
        expect(instance.payload?.id) == 100
      }

      it("configures an instance with a dependency when the module doesn't require a payload") {
        let instance = ConfiguratorFixture<Dependency, Void>()
        instance.configure(dependency: .init(networking: "Networking B"))
        expect(instance.dependency?.networking) == "Networking B"
        expect(instance.payload) == Void()
      }

      it("configures an instance with a payload when the module doesn't require a dependency") {
        let instance = ConfiguratorFixture<Void, Payload>()
        instance.configure(payload: .init(id: 200))
        expect(instance.dependency) == Void()
        expect(instance.payload?.id) == 200
      }

      it("configures an instance when the module doesn't require a dependency and a payload") {
        let instance = ConfiguratorFixture<Void, Void>()
        instance.configure()
        expect(instance.dependency) == Void()
        expect(instance.payload) == Void()
      }
    }

    describe("a factory") {
      it("creates an instance with a dependency and a payload") {
        let factory = FactoryFixture<Dependency, Payload>.Factory(dependency: .init(
          networking: "Networking A"
        ))
        let instance = factory.create(payload: .init(id: 100))
        expect(instance.dependency.networking) == "Networking A"
        expect(instance.payload.id) == 100
      }

      it("creates an instance with a dependency when the module doesn't require a payload") {
        let factory = FactoryFixture<Dependency, Void>.Factory(dependency: .init(
          networking: "Networking B"
        ))
        let instance = factory.create()
        expect(instance.dependency.networking) == "Networking B"
        expect(instance.payload) == Void()
      }

      it("creates an instance with a payload when the module doesn't require a dependency") {
        let factory = FactoryFixture<Void, Payload>.Factory()
        let instance = factory.create(payload: .init(id: 200))
        expect(instance.dependency) == Void()
        expect(instance.payload.id) == 200
      }

      it("creates an instance when the module doesn't require a dependency and a payload") {
        let factory = FactoryFixture<Void, Void>.Factory()
        let instance = factory.create()
        expect(instance.dependency) == Void()
        expect(instance.payload) == Void()
      }

      it("dependency should be initialized once") {
        var dependencyInitializedCount = 0
        let dependencyInitializer: () -> Dependency = {
          dependencyInitializedCount += 1
          return .init(
            networking: "Networking B"
          )
        }
        let factory = FactoryFixture<Dependency, Void>.Factory(dependency: dependencyInitializer())

        for _ in 0..<4 {
          _ = factory.create()
        }

        expect(dependencyInitializedCount) == 1
      }
    }

    describe("a configurator") {
      it("configures an instance with a dependency and a payload") {
        let instance = ConfiguratorFixture<Dependency, Payload>()
        let configurator = ConfiguratorFixture<Dependency, Payload>.Configurator(dependency: .init(
          networking: "Networking A"
        ))
        configurator.configure(instance, payload: .init(id: 100))
        expect(instance.dependency?.networking) == "Networking A"
        expect(instance.payload?.id) == 100
      }

      it("configures an instance with a dependency when the module doesn't require a payload") {
        let instance = ConfiguratorFixture<Dependency, Void>()
        let configurator = ConfiguratorFixture<Dependency, Void>.Configurator(dependency: .init(
          networking: "Networking B"
        ))
        configurator.configure(instance)
        expect(instance.dependency?.networking) == "Networking B"
        expect(instance.payload) == Void()
      }

      it("configures an instance with a payload when the module doesn't require a dependency") {
        let instance = ConfiguratorFixture<Void, Payload>()
        let configurator = ConfiguratorFixture<Void, Payload>.Configurator()
        configurator.configure(instance, payload: .init(id: 200))
        expect(instance.dependency) == Void()
        expect(instance.payload?.id) == 200
      }

      it("configures an instance when the module doesn't require a dependency and a payload") {
        let instance = ConfiguratorFixture<Void, Void>()
        let configurator = ConfiguratorFixture<Void, Void>.Configurator()
        configurator.configure(instance)
        expect(instance.dependency) == Void()
        expect(instance.payload) == Void()
      }

      it("dependency should be initialized once") {
        var dependencyInitializedCount = 0
        let dependencyInitializer: () -> Dependency = {
          dependencyInitializedCount += 1
          return .init(
            networking: "Networking B"
          )
        }
        let instance = ConfiguratorFixture<Dependency, Void>()
        let configurator = ConfiguratorFixture<Dependency, Void>.Configurator(dependency: dependencyInitializer())

        for _ in 0..<4 {
          configurator.configure(instance)
        }

        expect(dependencyInitializedCount) == 1
      }
    }

    it("is thread-safe") {
      final class MyClass: FactoryModule {
        static var dependencyInitializerExecutionCount = 0

        struct Dependency {
          init() {
            MyClass.dependencyInitializerExecutionCount += 1
            sleep(1)
          }
        }

        struct Payload {
        }

        init(dependency: Dependency, payload: Payload) {
        }
      }

      let factory = MyClass.Factory(dependency: .init())
      for _ in 0..<100 {
        DispatchQueue.global().async {
          _ = factory.create(payload: .init())
        }
      }

      XCTWaiter().wait(for: [XCTestExpectation()], timeout: 1)
      expect(MyClass.dependencyInitializerExecutionCount) == 1
    }
  }
}

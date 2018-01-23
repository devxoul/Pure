import Pure

class UserDetailViewController: FactoryModule {
  struct Dependency {
    let reactorFactory: UserDetailViewReactor.Factory
    let analytics: AnalyticsType
  }
  struct Payload {
    let reactor: UserDetailViewReactor
  }

  private let reactor: UserDetailViewReactor

  required init(dependency: Dependency, payload: Payload) {
    self.reactor = payload.reactor
    print("Create UserDetailViewController payload=\(payload)")
  }
}

extension Factory where Module == UserDetailViewController {
  func create(payload: UserDetailViewReactor.Payload) -> Module {
    let reactor = self.dependency().reactorFactory.create(payload: payload)
    return Module(dependency: self.dependency(), payload: .init(reactor: reactor))
  }
}

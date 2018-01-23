import Pure

class UserDetailViewReactor: FactoryModule {
  struct Dependency {
    let userService: UserServiceType
  }
  struct Payload {
    let userID: Int
  }

  required init(dependency: Dependency, payload: Payload) {
    print("Create UserDetailViewReactor payload=\(payload)")
  }
}

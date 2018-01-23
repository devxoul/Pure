import Pure

class UserListViewController: FactoryModule {
  struct Dependency {
    let userService: UserServiceType
    let userListViewCellConfigurator: UserListViewCell.Configurator
    let userDetailViewControllerFactory: UserDetailViewController.Factory
  }

  struct Payload {
    let reactor: UserListViewReactor
  }

  private let dependency: Dependency

  required init(dependency: Dependency, payload: Payload) {
    self.dependency = dependency

    let userIDs = Array(1...5)
    let cells = userIDs.map { _ in UserListViewCell() }
    for (i, userID) in userIDs.enumerated() {
      let cell = cells[i]
      self.dependency.userListViewCellConfigurator.configure(cell, payload: .init(userID: userID))
    }
  }

  func presentDetailViewController(userID: Int) {
    _ = self.dependency.userDetailViewControllerFactory.create(payload: .init(userID: userID))
  }
}

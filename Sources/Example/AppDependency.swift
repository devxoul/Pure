struct AppDependency {
  let rootViewController: UserListViewController
}

extension AppDependency {
  static func resolve() -> AppDependency {
    let userService = UserService()
    let analytics = Analytics()

    let userListViewReactorFactory = UserListViewReactor.Factory()
    let userDetailViewReactorFactory = UserDetailViewReactor.Factory(dependency: .init(userService: userService))

    let userListViewControllerFactory = UserListViewController.Factory(dependency: .init(
      userService: userService,
      userListViewCellConfigurator: UserListViewCell.Configurator(),
      userDetailViewControllerFactory: UserDetailViewController.Factory(dependency: .init(
        reactorFactory: userDetailViewReactorFactory,
        analytics: analytics
      ))
    ))

    return .init(
      rootViewController: userListViewControllerFactory.create(payload: .init(
        reactor: userListViewReactorFactory.create()
      ))
    )
  }
}

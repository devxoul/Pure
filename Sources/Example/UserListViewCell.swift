import Pure

class UserListViewCell: ConfiguratorModule {
  struct Payload {
    let userID: Int
  }

  func configure(dependency: Dependency, payload: Payload) {
    print("Configure UserListViewCell userID=\(payload.userID)")
  }
}

//
// UserEndpointReponse_tests.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChatClient_v3

extension UserEndpointReponse {
  static func createMock() -> UserEndpointReponse<NameAndAvatarUserData> {
    .init(
      id: .unique,
      role: .admin,
      extraData: .init(name: "Luke", avatarURL: nil),
      created: .random,
      updated: .random,
      lastActiveDate: .random,
      isInvisible: .random(),
      isOnline: .random(),
      isBanned: .random()
    )
  }
}

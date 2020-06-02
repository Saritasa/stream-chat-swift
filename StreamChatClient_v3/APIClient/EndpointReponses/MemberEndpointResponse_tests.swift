//
// MemberEndpointResponse_tests.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChatClient_v3

extension MemberEndpointResponse {
  static func createMock() -> MemberEndpointResponse<NameAndAvatarUserData> {
    .init(user: .createMock())
  }
}

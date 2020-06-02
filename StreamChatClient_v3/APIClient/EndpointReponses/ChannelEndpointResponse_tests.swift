//
// ChannelEndpointResponse_tests.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChatClient_v3

extension ChannelEndpointResponse {
  static func createMock() -> ChannelEndpointResponse<DefaultDataTypes> {
    .init(channel: .init(id: .unique, extraData: nil), members: [.createMock()])
  }
}

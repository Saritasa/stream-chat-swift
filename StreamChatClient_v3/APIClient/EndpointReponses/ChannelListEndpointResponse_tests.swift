//
// ChannelListEndpointResponse_tests.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChatClient_v3

extension ChannelListEndpointResponse {
  static func createMock() -> ChannelListEndpointResponse<DefaultDataTypes> {
    .init(channels: [.createMock()])
  }
}

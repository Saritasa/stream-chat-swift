//
// ChannelEventsHandler_tests.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
@testable import StreamChatClient_v3
import XCTest

class ChannelEventsHandlerTests: WorkerTestCase<ChannelEventsHandler<DefaultDataTypes>> {
  func test_AddedToChannelEvent_isHandled() {
    let member = User(id: "test_user_\(UUID().uuidString)", name: "Luke", avatarURL: nil)
    let channel = Channel(id: "test_channel_\(UUID().uuidString)", extraData: nil, members: [member], queries: [])
    let event = AddedToChannel(channel: channel)

    webSocketClient.simulate(event: event)

    var loadedChannel: Channel? { database.viewContext.loadChannel(id: channel.id) }
    AssertAsync {
      Assert.willBeEqual(loadedChannel?.id, channel.id)
      Assert.willBeEqual(loadedChannel?.members, channel.members)
    }
  }
}

//
// ChannelQueryUpdater_tests.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

@testable import StreamChatClient_v3
import XCTest

class ChannelQueryUpdaterTests: WorkerTestCase<ChannelQueryUpdater<DefaultDataTypes>> {
  var query: ChannelListQuery!

  override func setUp() {
    super.setUp()

    query = ChannelListQuery(
      filter: .equal("id", to: UUID().uuidString),
      sort: [.init("id", isAscending: .random())],
      pagination: .init(minimumCapacity: .random(in: 1 ... 10)),
      messagesLimit: .init(minimumCapacity: .random(in: 1 ... 10)),
      options: .all
    )
  }

  func test_callingUpdate_makesAPICall() {
    worker.update(channelListQuery: query)

    let referenceEndpoint = Endpoint.channels(query: query)
    XCTAssertEqual(apiClient.requestCalledWithEndpoint, referenceEndpoint)
  }

  func test_callingUpdate_handlesSuccess() {
    let response = ChannelListEndpointResponse<DefaultDataTypes>.createMock()
    apiClient.simulatedResponse = .success(response)

    worker.update(channelListQuery: query)

    var loadedChannel: Channel? { database.viewContext.loadChannel(id: response.channels[0].channel.id) }
    AssertAsync {
      Assert.willBeEqual(loadedChannel?.id, response.channels[0].channel.id)
      Assert.willBeTrue(loadedChannel?.queries.contains(self.query.filter.sha256) ?? false)
    }
  }
}

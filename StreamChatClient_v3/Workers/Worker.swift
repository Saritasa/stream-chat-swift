//
// Worker.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

typealias WorkerBuilder = (
  _ storageContext: NSManagedObjectContext,
  _ webSocketClient: WebSocketClient,
  _ apiClient: APIClient
) -> Worker

// This is a super-class instead of protocol because:
// - we need to be sure, `unowned` is used for socket client and api client
// - it's painfull to work with protocols with associated types
class Worker {
  let context: NSManagedObjectContext
  unowned let webSocketClient: WebSocketClient
  unowned let apiClient: APIClient

  init(storageContext: NSManagedObjectContext, webSocketClient: WebSocketClient, apiClient: APIClient) {
    self.context = storageContext
    self.webSocketClient = webSocketClient
    self.apiClient = apiClient
  }
}

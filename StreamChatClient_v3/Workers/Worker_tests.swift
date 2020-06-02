//
// Worker_tests.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

@testable import StreamChatClient_v3
import XCTest

class WorkerTestCase<Worker: StreamChatClient_v3.Worker>: XCTestCase {
  var worker: Worker!

  var database: DatabaseContainer!
  var webSocketClient: WebSocketClientMock!
  var apiClient: APIClientMock!

  override func setUp() {
    super.setUp()

    database = try! DatabaseContainer(kind: .inMemory)
    webSocketClient = WebSocketClientMock()
    apiClient = APIClientMock()

    worker = .init(database: database, webSocketClient: webSocketClient, apiClient: apiClient)
  }
}

// Where to put these????

class WebSocketClientMock: WebSocketClient {
  func simulate(event: Event) {
    notificationCenter.post(Notification(newEventReceived: event, sender: self))
  }

  init() {
    struct MockDecoder: AnyEventDecoder {
      func decode(data: Data) throws -> Event { fatalError() }
    }

    super.init(
      urlRequest: URLRequest(url: URL(string: "test")!),
      eventDecoder: MockDecoder(),
      callbackQueue: .main
    )
  }
}

class APIClientMock: APIClient {
  var simulatedResponse: Result<Any, Error>?
  var requestCalledWithEndpoint: Endpoint?

  init() {
    super.init(apiKey: "", baseURL: URL(string: "test")!, sessionConfiguration: .default)
  }

  override func request<T>(endpoint: Endpoint, _ completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
    requestCalledWithEndpoint = endpoint
    if let simulatedResponse = simulatedResponse {
      switch simulatedResponse {
      case .success(let object):
        completion(.success(object as! T))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

extension Endpoint: Equatable {
  public static func ==(lhs: Endpoint, rhs: Endpoint) -> Bool {
    // TODO: fix!
    lhs.path == rhs.path &&
      lhs.method == rhs.method &&
      lhs.queryItems == rhs.queryItems &&
      lhs.body == rhs.body
  }
}

extension String {
  static var unique: String {
    UUID().uuidString
  }
}

extension Date {
  static var random: Date {
    .init(timeIntervalSince1970: .random(in: 1000 ... 100000))
  }
}

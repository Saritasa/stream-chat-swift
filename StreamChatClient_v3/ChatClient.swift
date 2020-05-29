//
// ChatClient.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

public protocol ExtraDataTypes {
  associatedtype Channel: Codable & Hashable
  associatedtype User: Codable & Hashable
  associatedtype Message: Codable & Hashable
}

public struct DefaultDataTypes: ExtraDataTypes {
  public typealias Channel = NoExtraChannelData
  public typealias User = NameAndAvatarUserData
  public typealias Message = NoExtraMessageData
}

public typealias ChatClient = Client<DefaultDataTypes>

/// The root object representing a Stream Chat.
///
/// If you don't need to specify your custom extra data types for `User`, `Channel`, or `Message`, use the convenient non-generic
/// typealias `ChatClient` which specifies the default extra data types.
///
public final class Client<ExtraData: ExtraDataTypes> {
  // MARK: - Public

  public let currentUser: UserModel<ExtraData.User>

  public let config: ChatClientConfig

  public convenience init(currentUser: UserModel<ExtraData.User>, config: ChatClientConfig) {
    // All production workers
    let workers: [WorkerBuilder] = [
      MessageSender.init,
      ChannelQuerryUpdater<ExtraData>.init
    ]

    self.init(
      currentUser: currentUser,
      config: config,
      workers: workers,
      environment: .init()
    )
  }

  // MARK: - Internal

  struct Environment {
    var apiClientBuilder: (_ apiKey: String, _ baseURL: URL, _ sessionConfiguration: URLSessionConfiguration)
      -> APIClient = APIClient.init
    var webSocketClientBuilder: (_ urlRequest: URLRequest) -> WebSocketClient = WebSocketClient.init
    var databaseContainerBuilder: (_ kind: DatabaseContainer.Kind) throws
      -> DatabaseContainer = { try DatabaseContainer(kind: $0) }
  }

  private var backgroundWorkers: [Worker]!

  private(set) lazy var apiClient: APIClient = self.environment
    .apiClientBuilder(self.config.apiKey, self.baseURL.baseURL, self.urlSessionConfiguration)

  private(set) lazy var webSocketClient: WebSocketClient = {
    let jsonParameter = WebSocketPayload<ExtraData>(user: self.currentUser, token: token)

    var urlComponents = URLComponents()
    urlComponents.scheme = baseURL.wsURL.scheme
    urlComponents.host = baseURL.wsURL.host
    urlComponents.path = baseURL.wsURL.path.appending("connect")
    urlComponents.queryItems = [URLQueryItem(name: "api_key", value: config.apiKey)]

//      if user.isAnonymous {
//          urlComponents.queryItems?.append(URLQueryItem(name: "stream-auth-type", value: "anonymous"))
//      } else {
    urlComponents.queryItems?.append(URLQueryItem(name: "authorization", value: token))
    urlComponents.queryItems?.append(URLQueryItem(name: "stream-auth-type", value: "jwt"))
    //      }

    let jsonData = try! JSONEncoder.default.encode(jsonParameter)

    if let jsonString = String(data: jsonData, encoding: .utf8) {
      urlComponents.queryItems?.append(URLQueryItem(name: "json", value: jsonString))
    } else {
      //          logger?.log("❌ Can't create a JSON parameter string from the json: \(jsonParameter)", level: .error)
    }

    guard let url = urlComponents.url else {
      fatalError()
      //          logger?.log("❌ Bad URL: \(urlComponents)", level: .error)
      //          throw ClientError.invalidURL(urlComponents.description)
    }

    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = authHeaders(token: token)

    //      let callbackQueue = DispatchQueue(label: "io.getstream.Chat.WebSocket", qos: .userInitiated)
    //      let webSocketOptions: WebSocketOptions = [] // = stayConnectedInBackground ? WebSocketOptions.stayConnectedInBackground : []
    //      let webSocketProvider = defaultWebSocketProviderType.init(request: request, callbackQueue: callbackQueue)

    return WebSocketClient(urlRequest: request)
  }()

  private(set) lazy var persistentContainer: DatabaseContainer = {
    if config.isLocalStorageEnabled {
      // Create the folder if needed
      try? FileManager.default.createDirectory(
        at: config.localStorageFolderURL,
        withIntermediateDirectories: true,
        attributes: nil
      )
      let dbFileURL = config.localStorageFolderURL.appendingPathComponent(currentUser.id)

      do {
        return try environment.databaseContainerBuilder(.onDisk(databaseFileURL: dbFileURL))
      } catch {
        // TODO: Log
        print("Failed to initalized the local storage with error: \(error). Falling back to the in-memory option.")
      }
    }

    do {
      return try environment.databaseContainerBuilder(.inMemory)
    } catch {
      fatalError("Failed to initialize the in-memory storage. This is a non-recoverable error.")
    }
  }()

  private let environment: Environment

  init(
    currentUser: UserModel<ExtraData.User>,
    config: ChatClientConfig,
    workers: [WorkerBuilder],
    environment: Environment
  ) {
    self.config = config
    self.currentUser = currentUser
    self.environment = environment

    apiClient.connectionIdProvider = webSocketClient

    // The background work initialization can be expensive so it's performed on a bakcground queue
    DispatchQueue.global().async {
      self.backgroundWorkers = workers.map { builder in
        builder(self.persistentContainer.writableContext, self.webSocketClient, self.apiClient)
      }
    }
  }
}

// MARKL: ========= TEMPORARY!

extension Client {
  var baseURL: BaseURL { .dublin }
  var token: String {
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiYnJva2VuLXdhdGVyZmFsbC01In0.d1xKTlD_D0G-VsBoDBNbaLjO-2XWNA8rlTm4ru4sMHg"
  }

  var urlSessionConfiguration: URLSessionConfiguration {
    let headers = authHeaders(token: token)
    let config = URLSessionConfiguration.default
    config.waitsForConnectivity = true
    config.httpAdditionalHeaders = headers
    return config
  }

  func authHeaders(token: String) -> [String: String] {
    var headers = [
      "X-Stream-Client": "stream-chat-swift-client-\(SystemEnvironment.version)",
      "X-Stream-Device": SystemEnvironment.deviceModelName,
      "X-Stream-OS": SystemEnvironment.systemName,
      "X-Stream-App-Environment": SystemEnvironment.name
    ]

    //      if token.isBlank || user.isAnonymous {
    //          headers["Stream-Auth-Type"] = "anonymous"
    //      } else {
    headers["Stream-Auth-Type"] = "jwt"
    headers["Authorization"] = token
    //      }

    if let bundleId = Bundle.main.id {
      headers["X-Stream-BundleId"] = bundleId
    }

    return headers
  }
}

//
// WebSocketPayload.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation

struct WebSocketPayload<ExtraData: ExtraDataTypes>: Encodable {
  private enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userDetails = "user_details"
    case token = "user_token"
    case serverDeterminesConnectionId = "server_determines_connection_id"
  }

  let userDetails: UserWebSocketPayload
  let userId: String
  let token: String
  let serverDeterminesConnectionId = true

  init(user: UserModel<ExtraData.User>, token: String) {
    self.userDetails = UserWebSocketPayload(user: user)
    self.userId = user.id
    self.token = token
  }
}

struct UserWebSocketPayload: Encodable {
  let id: String

  init<ExtraData: UserExtraData>(user: UserModel<ExtraData>) {
    self.id = user.id
  }
}

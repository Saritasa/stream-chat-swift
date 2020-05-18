//
//  Endpoint.swift
//  StreamChatCore
//
//  Created by Alexey Bukhtin on 01/04/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

public struct Endpoint: Equatable {
    let method: Method = .get
    let path: String = ""
    
    let queryItemss: [URLQueryItem]? = nil
    
    let body: JSON? = nil
    let multipartFormData: MultipartFormData? = nil
    
    let requiresConnectionId: Bool = false
}

struct JSON: Equatable {

    init()
}

/// Chat endpoints
extension Endpoint {
    // MARK: Auth Endpoints
       
       /// Get a guest token.
    static func guestToken(user: User) -> Endpoint { .init() }
       
    // MARK: Device Endpoints
       
    /// Add a device with a given identifier for Push Notifications.
    static func add(device deviceId: String, user: User) -> Endpoint { .init() }
    /// Get a list of devices.
    static func devices(of user: User) -> Endpoint { .init() }
    /// Remove a device with a given identifier.
    static func remove(device deviceId: String, user: User) -> Endpoint { .init() }
       
   // MARK: Client Endpoints
       
       /// Get a list of channels.
    static func channels(query: ChannelsQuery) -> Endpoint { .init() }
       /// Get a message by id.
    static func message(id: String) -> Endpoint { .init() }
    /// Mark all messages as static read.
    static func markAllRead() -> Endpoint { .init() }
       
       /// Message search.
    static func search(query: SearchQuery) -> Endpoint { .init() }
       
       // MARK: - Channel Endpoints
       
       /// Get a channel data.
    static func channel(query: ChannelQuery) -> Endpoint { .init() }
       /// Stop watching a channel.
    static func stopWatching(channel: Channel) -> Endpoint { .init() }
       /// Update a channel.
    static func updateChannel(update: ChannelUpdate) -> Endpoint { .init() }
       /// Delete a channel.
    static func delete(channel: Channel) -> Endpoint { .init() }
       /// Hide a channel.
    static func hide(channel: Channel, user: User, clearHistory: Bool) -> Endpoint { .init() }
       /// Show a channel if it was hidden.
    static func show(channel: Channel, user: User) -> Endpoint { .init() }
       /// Send a message to a channel.
    static func send(message: Message, to channel: Channel) -> Endpoint { .init() }
       /// Upload an image to a channel.
    
    static func send(image data: Data, fileName: String, mimeType: String, to channel: Channel) -> Endpoint { .init() }
       /// Upload a file to a channel.
    static func send(file data: Data, fileName: String, mimeType: String, to channel: Channel) -> Endpoint { .init() }
       // Delete an uploaded image.
    
    static func delete(image url: URL, in channel: Channel) -> Endpoint { .init() }
       // Delete an uploaded file.
    static func delete(file url: URL, in channel: Channel) -> Endpoint { .init() }
       /// Send a read event.
    static func markRead(channel: Channel) -> Endpoint { .init() }
       /// Send an event to a channel.
    static func send(event: EventType, to channel: Channel) -> Endpoint { .init() }
       /// Send a message action.
    static func send(MessageAction: MessageAction) -> Endpoint { .init() }
       /// Add members to the channel
    static func add(users: Set<User>, to channel: Channel) -> Endpoint { .init() }
       /// Remove members to the channel
    static func remove(members: Set<Member>, of channel: Channel) -> Endpoint { .init() }
       /// Invite members.
    static func invite(users: Set<Member>, to channel: Channel) -> Endpoint { .init() }
       /// Send an answer for an invite.
    static func invite(answer: ChannelInviteAnswer) -> Endpoint { .init() }
       
       /// Get a thread data.
    static func replies(message: Message, pagination: Pagination) -> Endpoint { .init() }
       /// Delete a message.
    static func delete(message: Message) -> Endpoint { .init() }
       /// Add a reaction to the message.
    static func add(reaction: Reaction) -> Endpoint { .init() }
       /// Delete a reaction from the message.
    static func delete(reactionType: String, of message: Message) -> Endpoint { .init() }
       /// Flag a message.
    static func flag(message: Message) -> Endpoint { .init() }
       /// Unflag a message.
    static func unflag(message: Message) -> Endpoint { .init() }
       
       // MARK: - User Endpoints
       
       /// Get a list of users.
    static func users(query: UsersQuery) -> Endpoint { .init() }
       /// Update a user.
    static func update(users: [User]) -> Endpoint { .init() }
       /// Mute a use.
    static func mute(user: User) -> Endpoint { .init() }
       /// Unmute a user.
    static func unmute(user: User) -> Endpoint { .init() }
       /// Flag a user.
    static func flag(user: User) -> Endpoint { .init() }
       /// Unflag a user.
    static func unflag(user: User) -> Endpoint { .init() }
       /// Ban a user.
    static func ban(userBan: UserBan) -> Endpoint { .init() }
}

/// Chat endpoints.
public enum Endpoint2 {
    
    // MARK: Auth Endpoints
    
    /// Get a guest token.
    case guestToken(user: User)
    
    // MARK: Device Endpoints
    
    /// Add a device with a given identifier for Push Notifications.
    case addDevice(deviceId: String, User)
    /// Get a list of devices.
    case devices(user: User)
    /// Remove a device with a given identifier.
    case removeDevice(deviceId: String, User)
    
    // MARK: Client Endpoints
    
    /// Get a list of channels.
    case channels(ChannelsQuery)
    /// Get a message by id.
    case message(String)
    /// Mark all messages as read.
    case markAllRead
    
    /// Message search.
    case search(SearchQuery)
    
    // MARK: - Channel Endpoints
    
    /// Get a channel data.
    case channel(ChannelQuery)
    /// Stop watching a channel.
    case stopWatching(Channel)
    /// Update a channel.
    case updateChannel(ChannelUpdate)
    /// Delete a channel.
    case deleteChannel(Channel)
    /// Hide a channel.
    case hideChannel(Channel, User, _ clearHistory: Bool)
    /// Show a channel if it was hidden.
    case showChannel(Channel, User)
    /// Send a message to a channel.
    case sendMessage(Message, Channel)
    /// Upload an image to a channel.
    case sendImage(Data, _ fileName: String, _ mimeType: String, Channel)
    /// Upload a file to a channel.
    case sendFile(Data, _ fileName: String, _ mimeType: String, Channel)
    // Delete an uploaded image.
    case deleteImage(URL, Channel)
    // Delete an uploaded file.
    case deleteFile(URL, Channel)
    /// Send a read event.
    case markRead(Channel)
    /// Send an event to a channel.
    case sendEvent(EventType, Channel)
    /// Send a message action.
    case sendMessageAction(MessageAction)
    /// Add members to the channel
    case addMembers(Set<Member>, Channel)
    /// Remove members to the channel
    case removeMembers(Set<Member>, Channel)
    /// Invite members.
    case invite(Set<Member>, Channel)
    /// Send an answer for an invite.
    case inviteAnswer(ChannelInviteAnswer)
    
    // MARK: - Message Endpoints
    
    /// Get a thread data.
    case replies(Message, Pagination)
    /// Delete a message.
    case deleteMessage(Message)
    /// Add a reaction to the message.
    case addReaction(Reaction)
    /// Delete a reaction from the message.
    case deleteReaction(String, Message)
    /// Flag a message.
    case flagMessage(Message)
    /// Unflag a message.
    case unflagMessage(Message)
    
    // MARK: - User Endpoints
    
    /// Get a list of users.
    case users(user: UsersQuery)
    /// Update a user.
    case updateUsers([User])
    /// Mute a use.
    case muteUser(user: User)
    /// Unmute a user.
    case unmuteUser(user: User)
    /// Flag a user.
    case flagUser(user: User)
    /// Unflag a user.
    case unflagUser(user: User)
    /// Ban a user.
    case ban(user: UserBan)
}

//extension Endpoint {
//    var method: Method {
//        switch self {
//        case .search, .channels, .message, .replies, .users, .devices:
//            return .get
//        case .removeDevice, .deleteChannel, .deleteMessage, .deleteReaction, .deleteImage, .deleteFile:
//            return .delete
//        default:
//            return .post
//        }
//    }
//
//    var path: String {
//        switch self {
//        case .guestToken:
//            return "guest"
//        case .addDevice,
//             .devices,
//             .removeDevice:
//            return "devices"
//        case .search:
//            return "search"
//        case .channels:
//            return "channels"
//        case .message(let messageId):
//            return "messages/\(messageId)"
//        case .markAllRead:
//            return "channels/read"
//        case .deleteChannel(let channel),
//             .invite(_, let channel),
//             .addMembers(_, let channel),
//             .removeMembers(_, let channel):
//            return path(to: channel)
//        case .channel(let query):
//            return path(to: query.channel, "query")
//        case .stopWatching(let channel):
//            return path(to: channel, "stop-watching")
//        case .updateChannel(let channelUpdate):
//            return path(to: channelUpdate.data.channel)
//        case .showChannel(let channel, _):
//            return path(to: channel, "show")
//        case .hideChannel(let channel, _, _):
//            return path(to: channel, "hide")
//        case .replies(let message, _):
//            return path(to: message.id, "replies")
//
//        case let .sendMessage(message, channel):
//            if message.id.isEmpty {
//                return path(to: channel, "message")
//            }
//
//            return path(to: message.id)
//
//        case .sendMessageAction(let messageAction):
//            return path(to: messageAction.message.id, "action")
//        case .deleteMessage(let message):
//            return path(to: message.id)
//        case .markRead(let channel):
//            return path(to: channel, "read")
//        case .addReaction(let reaction):
//            return path(to: reaction.messageId, "reaction")
//        case .deleteReaction(let reactionType, let message):
//            return path(to: message.id, "reaction/\(reactionType)")
//        case .sendEvent(_, let channel):
//            return path(to: channel, "event")
//        case .sendImage(_, _, _, let channel):
//            return path(to: channel, "image")
//        case .sendFile(_, _, _, let channel):
//            return path(to: channel, "file")
//        case .deleteImage(_, let channel):
//            return path(to: channel, "image")
//        case .deleteFile(_, let channel):
//            return path(to: channel, "file")
//        case .users, .updateUsers:
//            return "users"
//        case .muteUser:
//            return "moderation/mute"
//        case .unmuteUser:
//            return "moderation/unmute"
//        case .flagUser,
//             .flagMessage:
//            return "moderation/flag"
//        case .unflagUser,
//             .unflagMessage:
//            return "moderation/unflag"
//        case .ban:
//            return "moderation/ban"
//        case .inviteAnswer(let answer):
//            return path(to: answer.channel)
//        }
//    }
//
//    var queryItem: Encodable? {
//        switch self {
//        case .removeDevice(deviceId: let deviceId, let user):
//            return ["id": deviceId, "user_id": user.id]
//        case .replies(_, let pagination):
//            return pagination
//        case .deleteImage(let url, _), .deleteFile(let url, _):
//            return ["url": url]
//        default:
//            return nil
//        }
//    }
//
//    var jsonQueryItems: [String: Encodable]? {
//        let payload: Encodable
//
//        switch self {
//        case .search(let query):
//            payload = query
//        case .channels(let query):
//            payload = query
//        case .users(let query):
//            payload = query
//        default:
//            return nil
//        }
//
//        return ["payload": payload]
//    }
//
//    var body: Encodable? {
//        switch self {
//        case .removeDevice,
//             .search,
//             .channels,
//             .message,
//             .deleteChannel,
//             .replies,
//             .deleteMessage,
//             .deleteReaction,
//             .sendImage,
//             .sendFile,
//             .deleteImage,
//             .deleteFile,
//             .users:
//            return nil
//
//        case .markAllRead,
//             .markRead,
//             .stopWatching:
//            return EmptyData.empty
//
//        case .updateChannel(let channelUpdate):
//            return channelUpdate
//
//        case .guestToken(let user):
//            return ["user": user]
//
//        case .addDevice(deviceId: let deviceId, let user):
//            return ["id": deviceId, "push_provider": "apn", "user_id": user.id]
//
//        case .devices(let user):
//            return ["user_id": user.id]
//
//        case .channel(let query):
//            return query
//
//        case .showChannel(_, let user):
//            return ["user_id": user.id]
//
//        case .hideChannel(_, let user, let clearHistory):
//            return HiddenChannelRequest(userId: user.id, clearHistory: clearHistory)
//
//        case .sendMessage(let message, _):
//            return ["message": message]
//
//        case .sendMessageAction(let messageAction):
//            return messageAction
//
//        case .addReaction(let reaction):
//            return ["reaction": reaction]
//
//        case .sendEvent(let event, _):
//            return ["event": ["type": event]]
//
//        case .updateUsers(let users):
//            let usersById: [String: User] = users.reduce([:]) { usersById, user in
//                var usersById = usersById
//                usersById[user.id] = user
//                return usersById
//            }
//
//            return ["users": usersById]
//
//        case .muteUser(let user), .unmuteUser(let user):
//            return ["target_id": user.id]
//
//        case .flagMessage(let message), .unflagMessage(let message):
//            return ["target_message_id": message.id]
//
//        case .flagUser(let user), .unflagUser(let user):
//            return ["target_user_id": user.id]
//
//        case .ban(let userBan):
//            return userBan
//
//        case .invite(let members, _):
//            return ["invites": members]
//
//        case .inviteAnswer(let answer):
//            return answer
//
//        case .addMembers(let members, _):
//            return ["add_members": members]
//
//        case .removeMembers(let members, _):
//            return ["remove_members": members]
//        }
//    }
//
//    var isUploading: Bool {
//        switch self {
//        case .sendImage,
//             .sendFile:
//            return true
//        default:
//            return false
//        }
//    }
//
//    var requiresConnectionId: Bool {
//        switch self {
//        case .users(let query):
//            return query.options.contains(.presence) || query.options.contains(.state)
//        case .channels(let query):
//            return query.options.contains(.presence) || query.options.contains(.state)
//        case .channel(let query):
//            return query.options.contains(.presence) || query.options.contains(.state)
//        case .updateUsers,
//             .stopWatching:
//            return true
//        case .guestToken,
//             .message,
//             .markAllRead,
//             .deleteChannel,
//             .invite,
//             .addMembers,
//             .removeMembers,
//             .replies,
//             .deleteMessage,
//             .deleteReaction,
//             .sendImage,
//             .sendFile,
//             .deleteImage,
//             .deleteFile,
//             .inviteAnswer,
//             .addDevice,
//             .removeDevice,
//             .devices,
//             .search,
//             .updateChannel,
//             .showChannel,
//             .hideChannel,
//             .sendMessage,
//             .sendMessageAction,
//             .markRead,
//             .addReaction,
//             .sendEvent,
//             .muteUser,
//             .unmuteUser,
//             .flagUser,
//             .unflagUser,
//             .flagMessage,
//             .unflagMessage,
//             .ban:
//            return false
//        }
//    }
//
//    private func path(to channel: Channel, _ subPath: String? = nil) -> String {
//        "channels/\(channel.type.rawValue)\(channel.id.isEmpty ? "" : "/\(channel.id)")\(subPath == nil ? "" : "/\(subPath ?? "")")"
//    }
//
//    private func path(to messageId: String, _ subPath: String? = nil) -> String {
//        return "messages/\(messageId)\(subPath == nil ? "" : "/\(subPath ?? "")")"
//    }
//}

// MARK: - Method

extension Endpoint {
    enum Method: String, Equatable {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }
}

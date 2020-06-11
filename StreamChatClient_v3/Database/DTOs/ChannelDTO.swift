//
// ChannelDTO.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

@objc(ChannelDTO)
class ChannelDTO: NSManagedObject {
  static let entityName = "ChannelDTO"

  @NSManaged fileprivate var id: String
  @NSManaged fileprivate var typeRawValue: String
  @NSManaged fileprivate var extraData: Data?
  @NSManaged fileprivate var config: Data

  @NSManaged fileprivate var createdDate: Date
  @NSManaged fileprivate var deletedDate: Date?
  @NSManaged fileprivate var lastMessageDate: Date?

  @NSManaged fileprivate var isFrozen: Bool

  // MARK: - Relationships

  @NSManaged fileprivate var createdBy: UserDTO
  @NSManaged fileprivate var team: TeamDTO?
  @NSManaged fileprivate var members: Set<MemberDTO>

  static func load(id: String, context: NSManagedObjectContext) -> ChannelDTO? {
    let request = NSFetchRequest<ChannelDTO>(entityName: ChannelDTO.entityName)
    request.predicate = NSPredicate(format: "id == %@", id)
    return try? context.fetch(request).first
  }

  static func loadOrCreate(id: String, context: NSManagedObjectContext) -> ChannelDTO {
    if let existing = Self.load(id: id, context: context) {
      return existing
    }

    let new = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! ChannelDTO
    new.id = id
    return new
  }
}

extension NSManagedObjectContext {
  func saveChannel<ExtraData: ExtraDataTypes>(_ channel: ChannelModel<ExtraData>) {
    fatalError()
//    let dto = ChannelDTO.loadOrCreate(id: channel.id.id, context: self)
//    if let extraData = channel.extraData {
//      dto.extraData = try? JSONEncoder.default.encode(extraData)
//    }
//
//    channel.members.forEach {
//      let user: UserDTO = self.saveUser($0)
//      dto.members.insert(user)
//    }
  }

  func saveChannel<ExtraData: ExtraDataTypes>(endpointResponse response: ChannelEndpointPayload<ExtraData>) {
    let dto = ChannelDTO.loadOrCreate(id: response.channel.id, context: self)
    if let extraData = response.channel.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    dto.typeRawValue = response.channel.typeRawValue
    dto.config = try! JSONEncoder.default.encode(response.channel.config)
    dto.createdDate = response.channel.created
    dto.deletedDate = response.channel.deleted
    dto.lastMessageDate = response.channel.lastMessageDate

    dto.isFrozen = response.channel.isFrozen

    let creatorDTO: UserDTO? = response.channel.createdBy.map { saveUser(endpointResponse: $0) }
    if let creatorDTO = creatorDTO {
      dto.createdBy = creatorDTO
    }

    // TODO: Team

    // TEMP
    response.members.forEach {
      let member: MemberDTO = saveMember(channelId: response.channel.cid, payload: $0)
      dto.members.insert(member)
    }
  }

  func loadChannel<ExtraData: ExtraDataTypes>(id: String) -> ChannelModel<ExtraData>? {
    guard let dto = ChannelDTO.load(id: id, context: self) else { return nil }

    let members: [UserModel<ExtraData.User>] = dto.members.compactMap { self.loadUser(id: $0.id) }

    var extraData: ExtraData.Channel?
    if let dtoExtraData = dto.extraData {
      extraData = try? JSONDecoder.default.decode(ExtraData.Channel.self, from: dtoExtraData)
    }

    fatalError()

//    return ChannelModel<ExtraData>(id: dto.id, extraData: extraData, members: Set(members))
  }
}

// To get the data from the DB

extension ChannelModel {
  static func channelsFetchRequest(query: ChannelListQuery) -> NSFetchRequest<ChannelDTO> {
    let request = NSFetchRequest<ChannelDTO>(entityName: "ChannelDTO")
    request.sortDescriptors = [.init(key: "id", ascending: true)]
    request.predicate = nil // TODO: Filter -> NSPredicate
    return request
  }
}

extension ChannelModel: LoadableEntity {
  /// Create a Channel struct from its DTO
  static func create(fromDTO dto: ChannelDTO) -> ChannelModel {
    let members = dto.members.map { MemberModel<ExtraData.User>.create(fromDTO: $0) }

    let extraData = dto.extraData.flatMap { try? JSONDecoder.default.decode(ExtraData.Channel.self, from: $0) }
    let channelType = ChannelType(rawValue: dto.typeRawValue)

    return ChannelModel(
      type: ChannelType(rawValue: dto.typeRawValue),
      id: ChannelId(type: channelType, id: dto.id),
      lastMessageDate: dto.lastMessageDate,
      created: dto.createdDate,
      deleted: dto.deletedDate,
      createdBy: UserModel<ExtraData.User>.create(fromDTO: dto.createdBy),
      config: try! JSONDecoder.default.decode(ChannelConfig.self, from: dto.config),
      frozen: dto.isFrozen,
      members: Set(members),
      watchers: [],
      team: "",
      unreadCount: .noUnread,
      watcherCount: 0,
      unreadMessageRead: nil,
      banEnabling: .disabled,
      isWatched: true,
      extraData: extraData,
      invitedMembers: []
    )
  }
}

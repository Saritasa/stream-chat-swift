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
  @NSManaged fileprivate var name: String

  @NSManaged fileprivate var extraData: Data?

  // This should eventually use `MemberDTO` when we have it
  @NSManaged fileprivate var members: Set<UserDTO>

  static func with(id: String, context: NSManagedObjectContext) -> ChannelDTO {
    let request = NSFetchRequest<ChannelDTO>(entityName: ChannelDTO.entityName)
    request.predicate = NSPredicate(format: "id == %@", id)

    if let existing = try? context.fetch(request).first {
      return existing
    }

    let new = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! ChannelDTO
    new.id = id
    return new
  }
}

extension NSManagedObjectContext {
  func saveChannel<ExtraData: ExtraDataTypes>(_ channel: ChannelModel<ExtraData>) {
    let dto = ChannelDTO.with(id: channel.id, context: self)
    if let extraData = channel.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    channel.members.forEach {
      let user: UserDTO = self.saveUser($0)
      dto.members.insert(user)
    }
  }

  func saveChannel<ExtraData: ExtraDataTypes>(endpointResponse response: ChannelEndpointResponse<ExtraData>) {
    let dto = ChannelDTO.with(id: response.channel.id, context: self)
    if let extraData = response.channel.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    // TEMP
    response.members.map { $0.user }.forEach {
      let user: UserDTO = saveUser(endpointResponse: $0)
      dto.members.insert(user)
    }
  }

  func loadChannel<ExtraData: ExtraDataTypes>(id: String) -> ChannelModel<ExtraData> {
    let dto = ChannelDTO.with(id: id, context: self)

    let members: [UserModel<ExtraData.User>] = dto.members.map { self.loadUser(id: $0.id) }
    let extraData = try? JSONDecoder.default.decode(ExtraData.Channel.self, from: dto.extraData!) // TODO: handle error

    return ChannelModel<ExtraData>(id: dto.id, extraData: extraData, members: Set(members))
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
  init(fromDTO entity: ChannelDTO) {
    id = entity.id
    members = Set(entity.members.map(UserModel<ExtraData.User>.init))
  }
}

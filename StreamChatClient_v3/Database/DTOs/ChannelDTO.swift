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

extension ChannelModel {
  @discardableResult
  func save(to context: NSManagedObjectContext) -> ChannelDTO {
    let dto = ChannelDTO.with(id: id, context: context)
    if let extraData = extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    members.forEach {
      let user = $0.save(to: context)
      dto.members.insert(user)
    }

    return dto
  }
}

// To save incoming data to DB

extension ChannelEndpointResponse {
  @discardableResult
  func save(to context: NSManagedObjectContext) -> ChannelDTO {
    let dto = ChannelDTO.with(id: channel.id, context: context)
    if let extraData = channel.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    members.forEach {
      let user = $0.save(to: context)
      dto.members.insert(user)
    }

    return dto
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

  /// Create a Channel struct from its DTO
  init(dto: ChannelDTO) {
    id = dto.id
    members = Set(dto.members.map(UserModel<ExtraData.User>.init))
  }
}

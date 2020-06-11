//
// MemberModelDTO.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData

@objc(MemberDTO)
class MemberDTO: NSManagedObject {
  static var entityName: String { "MemberDTO" }

  @NSManaged var id: String // combination of channelId + userId

  @NSManaged var channelRoleRaw: String
//  @NSManaged var invitedAcceptedDate: Date?
//  @NSManaged var invitedRejectedDate: Date?
//  @NSManaged var isInvited: Bool
  @NSManaged var memberCreatedDate: Date
  @NSManaged var memberUpdatedDate: Date

  // MARK: - Relationships

  @NSManaged var user: UserDTO

  static func load(id: String, context: NSManagedObjectContext) -> MemberDTO? {
    let request = NSFetchRequest<MemberDTO>(entityName: MemberDTO.entityName)
    request.predicate = NSPredicate(format: "id == %@", id)
    return try? context.fetch(request).first
  }

  /// If a User with the given id exists in the context, fetches and returns it. Otherwise create a new
  /// `UserDTO` with the given id.
  ///
  /// - Parameters:
  ///   - id: The id of the user to fetch
  ///   - context: The context used to fetch/create `UserDTO`
  ///
  static func loadOrCreate(id: String, context: NSManagedObjectContext) -> MemberDTO {
    if let existing = Self.load(id: id, context: context) {
      return existing
    }

    let new = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! MemberDTO
    new.id = id
    return new
  }
}

extension NSManagedObjectContext {
  func saveMember<ExtraUserData: Codable & Hashable>(channelId: String,
                                                     payload: MemberEndpointPayload<ExtraUserData>) -> MemberDTO {
    let dto = MemberDTO.loadOrCreate(id: channelId + payload.user.id, context: self)

    // Save user-part of member first
    dto.user = saveUser(endpointResponse: payload.user)

    // Save member specific data
    dto.channelRoleRaw = payload.roleRawValue
    dto.memberCreatedDate = payload.created
    dto.memberUpdatedDate = payload.updated

    return dto
  }
}

extension MemberModel {
  static func create(fromDTO dto: MemberDTO) -> MemberModel {
    let extraData = dto.user.extraData.flatMap { try? JSONDecoder.default.decode(ExtraData.self, from: $0) }

    return MemberModel(
      id: dto.user.id,
      isOnline: dto.user.isOnline,
      isBanned: dto.user.isBanned,
      userRole: UserRole(rawValue: dto.user.userRoleRaw)!,
      userCreatedDate: dto.user.userCreatedDate,
      userUpdatedDate: dto.user.userUpdatedDate,
      lastActiveDate: dto.user.lastActivityDate,
      extraData: extraData,
      channelRole: ChannelRole(rawValue: dto.channelRoleRaw)!,
      memberCreatedDate: dto.memberCreatedDate,
      memberUpdatedDate: dto.memberUpdatedDate,
      isInvited: false,
      inviteAcceptedDate: nil,
      inviteRejectedDate: nil
    )
  }
}

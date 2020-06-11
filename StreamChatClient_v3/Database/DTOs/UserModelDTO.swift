//
// UserModelDTO.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

@objc(UserDTO)
class UserDTO: NSManagedObject {
  class var entityName: String { "UserDTO" }

  @NSManaged var extraData: Data?
  @NSManaged var id: String
  @NSManaged var isBanned: Bool
  @NSManaged var isOnline: Bool
  @NSManaged var lastActivityDate: Date?
  @NSManaged var teams: String
  @NSManaged var userCreatedDate: Date
  @NSManaged var userRoleRaw: String
  @NSManaged var userUpdatedDate: Date

  class func load(id: String, context: NSManagedObjectContext) -> UserDTO? {
    let request = NSFetchRequest<UserDTO>(entityName: UserDTO.entityName)
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
  class func loadOrCreate(id: String, context: NSManagedObjectContext) -> UserDTO {
    if let existing = Self.load(id: id, context: context) {
      return existing
    }

    let new = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! UserDTO
    new.id = id
    return new
  }
}

extension NSManagedObjectContext {
  func saveUser<ExtraUserData: Codable & Hashable>(_ user: UserModel<ExtraUserData>) {
    let _: UserDTO = saveUser(user)
  }

  func saveUser<ExtraUserData: Codable & Hashable>(_ user: UserModel<ExtraUserData>) -> UserDTO {
    let dto = UserDTO.loadOrCreate(id: user.id, context: self)

    if let extraData = user.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    return dto
  }

  func saveUser<ExtraUserData: Codable & Hashable>(endpointResponse response: UserEndpointPayload<ExtraUserData>) {
    let _: UserDTO = saveUser(endpointResponse: response)
  }

  func saveUser<ExtraUserData: Codable & Hashable>(endpointResponse response: UserEndpointPayload<ExtraUserData>) -> UserDTO {
    let dto = UserDTO.loadOrCreate(id: response.id, context: self)

    dto.isBanned = response.isBanned
    dto.isOnline = response.isOnline
    dto.lastActivityDate = response.lastActiveDate
    dto.userCreatedDate = response.created
    dto.userRoleRaw = response.roleRawValue
    dto.userUpdatedDate = response.updated

    // TODO: TEAMS

    if let extraData = response.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }
    return dto
  }

  func loadUser<ExtraData: UserExtraData>(id: String) -> UserModel<ExtraData>? {
    guard let dto = UserDTO.load(id: id, context: self) else { return nil }
    var extraData: ExtraData?
    if let dtoExtraData = dto.extraData {
      extraData = try? JSONDecoder.default.decode(ExtraData.self, from: dtoExtraData)
    }

    return UserModel<ExtraData>(id: id, extraData: extraData)
  }
}

extension UserModel {
  static func create(fromDTO dto: UserDTO) -> UserModel {
    let extraData = dto.extraData.flatMap { try? JSONDecoder.default.decode(ExtraData.self, from: $0) }

    return UserModel(
      id: dto.id,
      isOnline: dto.isOnline,
      isBanned: dto.isBanned,
      userRole: UserRole(rawValue: dto.userRoleRaw)!,
      createdDate: dto.userCreatedDate,
      updatedDate: dto.userUpdatedDate,
      lastActiveDate: dto.lastActivityDate,
      extraData: extraData
    )
  }
}

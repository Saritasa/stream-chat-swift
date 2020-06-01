//
// UserDTO.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

@objc(UserDTO)
public class UserDTO: NSManagedObject {
  static let entityName = "UserDTO"

  @NSManaged var id: String
  @NSManaged var extraData: Data?

  /// If an User with the given id exists in the context, fetches and returns it. Otherwise create a new
  /// `UserDTO` with the given id.
  ///
  /// - Parameters:
  ///   - id: The id of the user to fetch
  ///   - context: The context used to fetch/create `UserDTO`
  ///
  static func with(id: String, context: NSManagedObjectContext) -> UserDTO {
    let request = NSFetchRequest<UserDTO>(entityName: UserDTO.entityName)
    request.predicate = NSPredicate(format: "id == %@", id)

    if let existing = try? context.fetch(request).first {
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
    let dto = UserDTO.with(id: user.id, context: self)

    if let extraData = user.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    return dto
  }

  func saveUser<ExtraUserData: Codable & Hashable>(endpointResponse response: UserEndpointReponse<ExtraUserData>) {
    let _: UserDTO = saveUser(endpointResponse: response)
  }

  func saveUser<ExtraUserData: Codable & Hashable>(endpointResponse response: UserEndpointReponse<ExtraUserData>) -> UserDTO {
    let dto = UserDTO.with(id: response.id, context: self)
    if let extraData = response.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }
    return dto
  }

  func loadUser<ExtraUserData: Codable & Hashable>(id: String) -> UserModel<ExtraUserData> {
    let dto = UserDTO.with(id: id, context: self)
    var user = UserModel<ExtraUserData>(id: dto.id)
    user.extraData = try? JSONDecoder.default.decode(ExtraUserData.self, from: dto.extraData!) // TODO: How to handle error here?
    return user
  }
}

extension UserModel: LoadableEntity {
  init(fromDTO entity: UserDTO) {
    self.id = entity.id
    self.extraData = try? JSONDecoder.default
      .decode(ExtraData.self, from: entity.extraData!) // how to handle failure here?
  }
}

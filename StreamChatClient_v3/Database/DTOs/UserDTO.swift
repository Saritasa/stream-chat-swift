//
// UserDTO.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

@objc(UserDTO)
public class UserDTO: NSManagedObject {
  static let entityName = "UserDTO"

  @NSManaged fileprivate var id: String
  @NSManaged fileprivate var extraData: Data?

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

// To save the data to the DB

extension UserModel {
  @discardableResult
  func save(to context: NSManagedObjectContext) -> UserDTO {
    let dto = UserDTO.with(id: id, context: context)

    if let extraData = extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    return dto
  }
}

// To save the data to the DB

extension MemberEndpointResponse {
  @discardableResult
  func save(to context: NSManagedObjectContext) -> UserDTO {
    let dto = UserDTO.with(id: user.id, context: context)

    if let extraData = user.extraData {
      dto.extraData = try? JSONEncoder.default.encode(extraData)
    }

    return dto
  }
}

// To get the data from the DB

extension UserModel {
  init(from dto: UserDTO) {
    self.id = dto.id
    self.extraData = try? JSONDecoder.default
      .decode(ExtraData.self, from: dto.extraData!) // how to handle failure here?
  }
}

//
// ChannelListQueryDTO.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

@objc(ChannelListQueryDTO)
class ChannelListQueryDTO: NSManagedObject {
  static let entityName = "ChannelListQueryDTO"

  @NSManaged var sha: String

  static func load(sha: String, context: NSManagedObjectContext) -> ChannelListQueryDTO? {
    let request = NSFetchRequest<ChannelListQueryDTO>(entityName: ChannelListQueryDTO.entityName)
    request.predicate = NSPredicate(format: "sha == %@", sha)
    return try? context.fetch(request).first
  }

  static func loadOrCreate(sha: String, context: NSManagedObjectContext) -> ChannelListQueryDTO {
    if let existing = Self.load(sha: sha, context: context) {
      return existing
    }

    let new = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! ChannelListQueryDTO
    new.sha = sha
    return new
  }
}

extension NSManagedObjectContext {
  func saveChannelListQuery(_ sha: String) -> ChannelListQueryDTO {
    ChannelListQueryDTO.loadOrCreate(sha: sha, context: self)
  }

  func saveChannelListQuery(_ sha: String) {
    let _: ChannelListQueryDTO = saveChannelListQuery(sha)
  }
}

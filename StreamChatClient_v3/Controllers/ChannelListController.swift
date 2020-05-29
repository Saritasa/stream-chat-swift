//
// ChannelListController.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

/// `ChannelListController` allows observing and mutating the list of channels specified by a channel query.
///
///  ... you can do this and that
///
public class ChannelListController<ExtraData: ExtraDataTypes>: NSObject, NSFetchedResultsControllerDelegate {
  // MARK: - Public

  public var query: ChannelListQuery

  public weak var delegate: ChannelListControllerDelegate?

  public private(set) lazy var channels: [ChannelModel<ExtraData>] = { fatalError("Call `startUpdating` first") }()

  /// Synchronously loads the data for the referenced object form the local cache and starts observing its changes.
  ///
  /// It also anynchronously fetches the data from the servers. If the remote data differs from the locally cached one,
  /// `ChannelReference` uses the `delegate` methods to inform about the changes.
  public func startUpdating() {
    try! fetchResultsController.performFetch()

    channels = fetchResultsController.fetchedObjects!.map(ChannelModel<ExtraData>.init)
    delegate?.controllerDidChangeChannels(changes: [])

    delegate?.controllerWillStartFetchingRemoteData()

    worker.update(channelListQuery: query) { error in
      self.delegate?.controllerDidStopFetchingRemoteData(success: error == nil)
    }
  }

  // MARK: - Internal

  private let worker: ChannelQuerryUpdater<ExtraData>
  private let viewContext: NSManagedObjectContext

  private lazy var fetchResultsController: NSFetchedResultsController<ChannelDTO> = {
    let request = Channel.channelsFetchRequest(query: self.query)
    return .init(
      fetchRequest: request,
      managedObjectContext: viewContext,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
  }()

  init(query: ChannelListQuery, viewContext: NSManagedObjectContext, worker: ChannelQuerryUpdater<ExtraData>) {
    self.viewContext = viewContext
    self.query = query
    self.worker = worker
  }

  // TODO: this will be private once we remove the `NSObject` requirement
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    channels = fetchResultsController.fetchedObjects!.lazy.map(ChannelModel<ExtraData>.init)
    delegate?.controllerDidChangeChannels(changes: [])
  }
}

public protocol ChannelListControllerDelegate: AnyObject {
  func controllerWillStartFetchingRemoteData()
  func controllerDidStopFetchingRemoteData(success: Bool)

  func controllerDidChangeChannels(changes: [Change<AnyChannel>])
}

// Default implementations of `ChannelListControllerDelegate` functions
public extension ChannelListControllerDelegate {
  func controllerWillStartFetchingRemoteData() {}
  func controllerDidStopFetchingRemoteData(success: Bool) {}

  func controllerDidChangeChannels(changes: [Change<AnyChannel>]) {}
}

extension Client {
  /// Creates a new `ChannelListController` with the provided channel query.
  ///
  /// - Parameter channelId: The id of the channel this controller represents.
  /// - Returns: A new instance of `ChannelController`.
  ///
  public func channelListController(query: ChannelListQuery) -> ChannelListController<ExtraData> {
    let worker = ChannelQuerryUpdater<ExtraData>(
      storageContext: persistentContainer.writableContext,
      webSocketClient: webSocketClient,
      apiClient: apiClient
    )
    return .init(query: query, viewContext: persistentContainer.viewContext, worker: worker)
  }
}

// WIP!
public enum Change<T> {
  case added(_ item: T)
  case updated(_ item: T)
  case moved(_ item: T)
  case removed(_ item: T)
}

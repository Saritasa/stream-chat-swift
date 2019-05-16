//
//  ChatViewController.swift
//  GetStreamChat
//
//  Created by Alexey Bukhtin on 03/04/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public final class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var style = ChatViewStyle()
    let disposeBag = DisposeBag()
    var reactionsView: ReactionsView?
    
    var scrollEnabled: Bool {
        return reactionsView == nil
    }
    
    public private(set) lazy var composerView: ComposerView = {
        let composerView = ComposerView(frame: .zero)
        composerView.style = style.composer
        return composerView
    }()
    
    private(set) lazy var composerCommands: ComposerHelperContainerView = {
        let container = ComposerHelperContainerView()
        container.backgroundColor = style.backgroundColor.isDark ? .chatDarkGray : .white
        container.titleLabel.text = "Commands"
        container.add(for: composerView)
        container.isHidden = true
        container.closeButton.isHidden = true
        
        if let channelConfig = channelPresenter?.channel.config {
            channelConfig.commands.forEach { command in
                let view = ComposerCommandView(frame: .zero)
                view.backgroundColor = container.backgroundColor
                view.update(command: command.name, args: command.args, description: command.description)
                container.containerView.addArrangedSubview(view)
                
                view.rx.tapGesture().when(.recognized)
                    .subscribe(onNext: { [weak self] _ in self?.addCommandToComposer(command: command.name) })
                    .disposed(by: self.disposeBag)
            }
        }
        
        return container
    }()
    
    public private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerMessageCell(style: style.incomingMessage)
        tableView.registerMessageCell(style: style.outgoingMessage)
        tableView.register(cellType: StatusTableViewCell.self)
        
        tableView.contentInset = UIEdgeInsets(top: 2 * .messageEdgePadding,
                                              left: 0,
                                              bottom: .messagesToComposerPadding,
                                              right: 0)
        
        view.insertSubview(tableView, at: 0)
        
        let footerView = ChatFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: .chatFooterHeight))
        footerView.backgroundColor = style.backgroundColor
        tableView.tableFooterView = footerView
        
        return tableView
    }()
    
    var channelPresenter: ChannelPresenter? {
        didSet {
            if let presenter = channelPresenter {
                Driver.merge(presenter.request, presenter.changes, presenter.ephemeralChanges)
                    .drive(onNext: { [weak self] in self?.updateTableView(with: $0) })
                    .disposed(by: disposeBag)
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupComposerView()
        setupTableView()
        updateTitle()
        channelPresenter?.load()
        tableView.scrollToBottom(animated: false)
        DispatchQueue.main.async { self.tableView.scrollToBottom(animated: false) }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startGifsAnimations()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGifsAnimations()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return style.backgroundColor.isDark ? .lightContent : .default
    }
    
    private func updateTitle() {
        guard title == nil, navigationItem.rightBarButtonItem == nil else {
            return
        }
        
        title = channelPresenter?.channel.name
        
        let channelAvatar = AvatarView(cornerRadius: .messageAvatarRadius)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: channelAvatar)
        
        channelAvatar.update(with: channelPresenter?.channel.imageURL,
                             name: channelPresenter?.channel.name,
                             baseColor: style.backgroundColor)
    }
}

// MARK: - Table View

extension ChatViewController {
    
    private func setupTableView() {
        tableView.backgroundColor = style.backgroundColor
        tableView.makeEdgesEqualToSuperview()
    }
    
    private func updateTableView(with changes: ViewChanges) {
        // Check if view is loaded nad visible.
        guard isVisible else {
            return
        }
        
        switch changes {
        case .none, .itemMoved:
            return
        case let .reloaded(row, position):
            tableView.reloadData()
            
            if scrollEnabled {
                UIView.layerAnimated(false) {
                    tableView.scrollToRow(at: IndexPath(row: row), at: position, animated: false)
                }
            }
        case let .itemAdded(row, reloadRow, forceToScroll):
            let indexPath = IndexPath(row: row)
            let needsToScroll = tableView.bottomContentOffset < .chatBottomThreshold
            
            tableView.update {
                tableView.insertRows(at: [indexPath], with: .none)
                
                if let reloadRow = reloadRow {
                    tableView.reloadRows(at: [IndexPath(row: reloadRow)], with: .none)
                }
            }
            
            if scrollEnabled, (forceToScroll || needsToScroll) {
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        case let .itemUpdated(row, message):
            tableView.update {
                tableView.reloadRows(at: [IndexPath(row: row)], with: .none)
            }
            
            if let reactionsView = reactionsView {
                reactionsView.update(with: message)
            }
        case .itemRemoved(let row):
            tableView.update {
                tableView.deleteRows(at: [IndexPath(row: row)], with: .none)
            }
        case let .footerUpdated(isUsersTyping):
            updateFooterView(isUsersTyping)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelPresenter?.itemsCount ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch channelPresenter?.item(at: indexPath.row) {
        case .loading?:
            return loadingCell(at: indexPath)
        case let .status(title, subtitle, highlighted)?:
            return statusCell(at: indexPath, title: title, subtitle: subtitle, highlighted: highlighted)
        case .message(let message)?:
            return messageCell(at: indexPath, message: message)
        default:
            return .unused
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let item = channelPresenter?.item(at: indexPath.row), case .message(let message) = item {
            willDisplay(cell: cell, at: indexPath, message: message)
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MessageTableViewCell {
            cell.free()
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

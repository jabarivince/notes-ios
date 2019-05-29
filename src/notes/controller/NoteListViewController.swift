//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import notesServices

class NoteListViewController: UITableViewController {
    let searchController: UISearchController
    private let addButtomItem:    UIBarButtonItem
    private let shareButtomItem:  UIBarButtonItem
    private let trashButton:      UIBarButtonItem
    private let selectAllButton:  UIBarButtonItem
    private let spacer:           UIBarButtonItem
    private let delegate:         NoteListViewService
    
    var searchText: String? {
        return searchController.searchBar.text
    }
    
    var state: NoteListViewState! {
        didSet {
            title                     = state.title
            tableView.backgroundView  = state.backgroundView
            tableView.isScrollEnabled = state.scrollingEnabled
            tableView.separatorStyle  = state.seperatorStyle
            editButtonItem.title      = state.editButtonTitle
            navigationController?.setToolbarHidden(state.toolbarIsHidden, animated: true)
            
            // Right bar buttom
            switch state.rightBarButtonState {
            case .add:
                navigationItem.rightBarButtonItem = addButtomItem
            case .share:
                navigationItem.rightBarButtonItem = shareButtomItem
            }
            
            // Enable or disable buttons
            selectAllButton.title     = state.selectButtonTitle
            trashButton.isEnabled     = state.trashButtonIsEnabled
            shareButtomItem.isEnabled = state.shareButtonIsEnabled
            selectAllButton.isEnabled = state.selectButtonIsEnabled
            navigationItem.rightBarButtonItem?.isEnabled = state.rightBarButtonIsEnabled
            navigationItem.leftBarButtonItem?.isEnabled  = state.leftBarButtonIsEnabled
        }
    }
    
    init() {
        selectAllButton  = UIBarButtonItem(title: nil, style: .plain,           target: nil, action: nil)
        addButtomItem    = UIBarButtonItem(barButtonSystemItem: .add,           target: nil, action: nil)
        shareButtomItem  = UIBarButtonItem(barButtonSystemItem: .action,        target: nil, action: nil)
        trashButton      = UIBarButtonItem(barButtonSystemItem: .trash,         target: nil, action: nil)
        spacer           = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        searchController = UISearchController(searchResultsController: nil)
        delegate      = NoteListViewService.shared
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate.controller = self
        setupTableView()
        setupNavBar()
        setupTargets()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        addObservers()
        delegate.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        searchController.dismiss(animated: false, completion: nil)
        removeObservers()
    }
    
    /// Animate screen rotation between portrait and landscape
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        func transition(_ content: UIViewControllerTransitionCoordinatorContext) {
            searchController.searchBar.frame.size.width = view.frame.size.width
        }
        
        coordinator.animate(alongsideTransition: transition, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        delegate.setEditing()
    }
    
    func addObservers() {
        respondTo(UIApplication.didBecomeActiveNotification,
                  with: #selector(delegate.respondToDidBecomeActiveNotification),
                  observer: delegate)
        
        respondTo(UIApplication.significantTimeChangeNotification,
                  with: #selector(delegate.respondToSignificantTimeChangeNotification),
                  observer: delegate)
    }
}

// MARK:- Initialize view / state
extension NoteListViewController {
    func setupNavBar() {
        editButtonItem.isEnabled          = false
        navigationItem.leftBarButtonItem  = editButtonItem
        navigationItem.rightBarButtonItem = addButtomItem
    }
    
    func setupTableView() {
        let headerView: UIView = {
            let width  = searchController.searchBar.frame.width
            let height = searchController.searchBar.frame.height
            let frame  = CGRect(x: 0, y: 0, width: width, height: height)
            let view   = UIView(frame: frame)
            view.addSubview(searchController.searchBar)
            return view
        }()
        
        /// Add a footer to satisfy UITableView height calculation.
        /// This way we avoid having empty white space at the bottom
        let footerView = UIView(frame: .zero)
        
        /// Search bar
        searchController.dimsBackgroundDuringPresentation     = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate                   = delegate
        searchController.searchBar.returnKeyType              = .done
        searchController.searchBar.sizeToFit()
        
        /// Main UITableView
        tableView.keyboardDismissMode                  = .interactive
        tableView.allowsSelectionDuringEditing         = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableHeaderView                      = headerView
        tableView.tableFooterView                      = footerView
        tableView.delegate                             = delegate
        tableView.dataSource                           = delegate
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.cellId)
    }
    
    /// Setup call to action (button) targets / navbar items
    func setupTargets() {
        trashButton.tintColor     = .red
        shareButtomItem.isEnabled = false
        trashButton.isEnabled     = false
        addButtomItem.target      = delegate
        shareButtomItem.target    = delegate
        trashButton.target        = delegate
        selectAllButton.target    = delegate
        addButtomItem.action      = #selector(delegate.handleAddButtonTapped)
        shareButtomItem.action    = #selector(delegate.handleShareButtonTapped)
        trashButton.action        = #selector(delegate.handleTrashButtonTapped)
        selectAllButton.action    = #selector(delegate.handleSelectAllButtonTapped)
        toolbarItems              = [selectAllButton, spacer, trashButton]
    }
    
    func setupAccessibility() {
        addButtomItem.accessibilityLabel   = "Create a new note"
        shareButtomItem.accessibilityLabel = "Share current selection"
        trashButton.accessibilityLabel     = "Delete current selection"
    }
}

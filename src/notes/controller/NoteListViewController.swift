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
    let addButtomItem:    UIBarButtonItem
    let shareButtomItem:  UIBarButtonItem
    let trashButton:      UIBarButtonItem
    let selectAllButton:  UIBarButtonItem
    let spacer:           UIBarButtonItem
    let viewService:      NoteListViewService
    
    var state: NoteListViewState! {
        didSet {
            title                     = state.title
            tableView.backgroundView  = state.backgroundView
            tableView.isScrollEnabled = state.scrollingEnabled
            tableView.separatorStyle  = state.seperatorStyle
            editButtonItem.title      = state.editButtonTitle
            selectAllButton.title     = state.selectButtonTitle
            trashButton.isEnabled     = state.trashButtonIsEnabled
            shareButtomItem.isEnabled = state.shareButtonIsEnabled
            navigationController?.setToolbarHidden(state.toolbarIsHidden, animated: true)
            
            switch state.rightBarButtonState {
            case .add:
                navigationItem.rightBarButtonItem = addButtomItem
            case .share:
                navigationItem.rightBarButtonItem = shareButtomItem
            }
            
            navigationItem.rightBarButtonItem?.isEnabled = state.rightBarButtonIsEnabled
            
            switch state.selectHandler {
            case .selectAll:
                tableView.selectAllRows()
            case .deselectAll:
                tableView.deselectAllRows()
            case .doNothing:
                break
            }
        }
    }
    
    init() {
        selectAllButton  = UIBarButtonItem(title: nil, style: .plain,           target: nil, action: nil)
        addButtomItem    = UIBarButtonItem(barButtonSystemItem: .add,           target: nil, action: nil)
        shareButtomItem  = UIBarButtonItem(barButtonSystemItem: .action,        target: nil, action: nil)
        trashButton      = UIBarButtonItem(barButtonSystemItem: .trash,         target: nil, action: nil)
        spacer           = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        searchController = UISearchController(searchResultsController: nil)
        viewService      = NoteListViewService.shared
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewService.controller = self
        setupTableView()
        setupNavBar()
        setupTargets()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        addObservers()
        viewService.getNotes()
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
        viewService.setEditing(editing, animated: animated)
    }
    
    func addObservers() {
        respondTo(UIApplication.didBecomeActiveNotification,       with: #selector(respondToDidBecomeActiveNotification))
        respondTo(UIApplication.significantTimeChangeNotification, with: #selector(respondToSignificantTimeChangeNotification))
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
        
        /// Add a footer to satisfy UITableView height calculation
        let footerView = UIView(frame: .zero)
        
        /// Search bar
        searchController.dimsBackgroundDuringPresentation     = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate                   = viewService
        searchController.searchBar.returnKeyType              = .done
        searchController.searchBar.sizeToFit()
        
        /// Main UITableView
        tableView.keyboardDismissMode                  = .interactive
        tableView.allowsSelectionDuringEditing         = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableHeaderView                      = headerView
        tableView.tableFooterView                      = footerView
        tableView.delegate                             = viewService
        tableView.dataSource                           = viewService
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.cellId)
    }
    
    /// Setup call to action (button) targets / navbar items
    func setupTargets() {
        trashButton.tintColor     = .red
        shareButtomItem.isEnabled = false
        trashButton.isEnabled     = false
        addButtomItem.target      = self
        shareButtomItem.target    = self
        trashButton.target        = self
        selectAllButton.target    = self
        addButtomItem.action      = #selector(handleAddButtonTapped)
        shareButtomItem.action    = #selector(handleShareButtonTapped)
        trashButton.action        = #selector(handleTrashButtonTapped)
        selectAllButton.action    = #selector(handleSelectAllButtonTapped)
        toolbarItems              = [selectAllButton, spacer, trashButton]
    }
    
    func setupAccessibility() {
        addButtomItem.accessibilityLabel   = "Create a new note"
        shareButtomItem.accessibilityLabel = "Share current selection"
        trashButton.accessibilityLabel     = "Delete current selection"
    }
}

// MARK:- Button taps / notification handlers
extension NoteListViewController {
    @objc func handleAddButtonTapped() {
        viewService.openNewNote()
    }
    
    @objc func handleShareButtonTapped() {
        viewService.sendMultipleNotes()
    }
    
    @objc func handleTrashButtonTapped() {
        viewService.deleteSelectedNotes()
    }
    
    @objc func handleSelectAllButtonTapped() {
        viewService.selectAllOrDeselectAllNotes()
    }
    
    @objc func respondToDidBecomeActiveNotification() {
        viewService.getNotes()
    }
    
    @objc func respondToSignificantTimeChangeNotification() {
        viewService.refreshCells()
    }
}

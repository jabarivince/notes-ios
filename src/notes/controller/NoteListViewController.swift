//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import notesServices

// MARK:- UITableViewController
class NoteListViewController: UITableViewController {
    private let searchController: UISearchController
    private let addButtomItem:    UIBarButtonItem
    private let shareButtomItem:  UIBarButtonItem
    private let trashButton:      UIBarButtonItem
    private let selectAllButton:  UIBarButtonItem
    private let spacer:           UIBarButtonItem
    private let cellId:           String
    private let noteService:      NoteService
    
    /// Data source for table view
    private var notes = [Note]() {
        didSet {
            editButtonItem.isEnabled = !notes.isEmpty
            determineAndSetBackground()
        }
    }
    
    /// Boolean flag that lets us know if the user
    /// is searching with the search bar or not
    private var isSearching = false {
        didSet {
            addButtomItem.isEnabled = !isSearching
            determineAndSetBackground()
        }
    }
    
    private var searchBar: UISearchBar {
        return searchController.searchBar
    }
    
    init() {
        selectAllButton  = UIBarButtonItem(title: nil, style: .plain,           target: nil, action: nil)
        addButtomItem    = UIBarButtonItem(barButtonSystemItem: .add,           target: nil, action: nil)
        shareButtomItem  = UIBarButtonItem(barButtonSystemItem: .action,        target: nil, action: nil)
        trashButton      = UIBarButtonItem(barButtonSystemItem: .trash,         target: nil, action: nil)
        spacer           = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        searchController = UISearchController(searchResultsController: nil)
        noteService      = NoteService.shared
        notes            = [Note]()
        cellId           = "cell"
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBar()
        setupTargets()
        setInitialState()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        addObservers()
        getNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        searchController.dismiss(animated: false, completion: nil)
        removeObservers()
    }
    
    /// Animate screen rotation between portrait and landscape
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        func transition(_ content: UIViewControllerTransitionCoordinatorContext) {
            searchBar.frame.size.width = view.frame.size.width
        }
        
        coordinator.animate(alongsideTransition: transition, completion: nil)
    }
    
    /// Set the state us the buttons based on whether or
    /// not the table is in editing mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            editButtonItem.title = "Done"
            navigationItem.rightBarButtonItem = shareButtomItem
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            setInitialState()
        }
    }
    
    func addObservers() {
        respondTo(notification: UIApplication.didBecomeActiveNotification,       with: #selector(getNotes))
        respondTo(notification: UIApplication.significantTimeChangeNotification, with: #selector(refreshCells))
    }
}

// MARK:- Initialize view / state
private extension NoteListViewController {
    func determineAndSetBackground() {
        let state: NoteListBackgroundView.State
        
        if !notes.isEmpty {
            state = .hidden
        } else {
            state = isSearching ? .noNotesFound : .noNotesAvailable
        }
        
        setupBackground(in: state)
    }
    
    private func setupBackground(in state: NoteListBackgroundView.State) {
        switch state {
        case .noNotesAvailable, .noNotesFound:
            let backgroundView        = NoteListBackgroundView(frame: tableView.frame)
            backgroundView.tapHandler   = openNewNote
            backgroundView.state      = state
            tableView.backgroundView  = backgroundView
            tableView.separatorStyle  = .none
            tableView.isScrollEnabled = false
        default:
            tableView.backgroundView  = nil
            tableView.separatorStyle  = .singleLine
            tableView.isScrollEnabled = true
        }
    }
    
    func setupNavBar() {
        editButtonItem.isEnabled          = false
        navigationItem.leftBarButtonItem  = editButtonItem
        navigationItem.rightBarButtonItem = addButtomItem
    }
    
    func setupTableView() {
        let headerView: UIView = {
            let width  = searchBar.frame.width
            let height = searchBar.frame.height
            let frame  = CGRect(x: 0, y: 0, width: width, height: height)
            let view   = UIView(frame: frame)
            view.addSubview(searchBar)
            return view
        }()
        
        /// Add a footer to satisfy UITableView height calculation
        let footerView = UIView(frame: .zero)
        
        /// Search bar
        searchController.dimsBackgroundDuringPresentation     = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchBar.delegate                                    = self
        searchBar.returnKeyType                               = .done
        searchBar.sizeToFit()
        
        /// Main UITableView
        tableView.keyboardDismissMode                  = .interactive
        tableView.allowsSelectionDuringEditing         = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableHeaderView                      = headerView
        tableView.tableFooterView                      = footerView
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    /// Setup call to action (button) targets / navbar items
    func setupTargets() {
        trashButton.tintColor     = .red
        shareButtomItem.isEnabled = false
        trashButton.isEnabled     = false
        spacer.target             = self
        addButtomItem.target      = self
        shareButtomItem.target    = self
        trashButton.target        = self
        selectAllButton.target    = self
        addButtomItem.action      = #selector(openNewNote)
        shareButtomItem.action    = #selector(sendMultipleNotes)
        trashButton.action        = #selector(deleteSelectedNotes)
        selectAllButton.action    = #selector(selectAllOrDeselectAllNotes)
        toolbarItems              = [selectAllButton, spacer, trashButton]
    }
    
    func setInitialState() {
        title = "Notes"
        editButtonItem.title  = "Select"
        selectAllButton.title = "Select all"
        
        addButtomItem.isEnabled = true
        shareButtomItem.isEnabled = false
        trashButton.isEnabled = false
        
        navigationItem.rightBarButtonItem = addButtomItem
        navigationController?.setToolbarHidden(true, animated: true)
        
        if atLeastOneNoteSelected {
            tableView.deselectAllRows()
        }
    }
    
    func setTitleForSelection() {
        title = "\(numberOfSelectedRows) Selected"
        selectAllButton.title = "Unselect \(numberOfSelectedRows) \(singularOrPlural)"
    }
    
    func setupAccessibility() {
        addButtomItem.accessibilityLabel   = "Create a new note"
        shareButtomItem.accessibilityLabel = "Share current selection"
        trashButton.accessibilityLabel     = "Delete current selection"
    }
}

// MARK: - UISearchBarDelegate
extension NoteListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getNotes()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text              = nil
        searchBar.showsCancelButton = false
        getNotes()
    }
}

// MARK:- UITableViewDelegate
extension NoteListViewController {
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if zeroNotesSelected {
            trashButton.isEnabled     = false
            shareButtomItem.isEnabled = false
            selectAllButton.title     = "Select all"
            title                     = "Notes"
        } else {
            setTitleForSelection()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        if isEditing {
            trashButton.isEnabled     = true
            shareButtomItem.isEnabled = true
            setTitleForSelection()
        } else {
            openNote(notes[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell   = tableView.dequeueReusableCell(withIdentifier: cellId) as! NoteTableViewCell
        let note   = notes[indexPath.row]
        let state  = NoteTableViewCellState(from: note)
        cell.state = state
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let note = notes.remove(at: indexPath.row)
        deleteNote(note)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if notes.isEmpty {
            determineAndSetBackground()
        } else {
            setupBackground(in: .hidden)
        }
        
        return 1
    }
}

private extension NoteListViewController {
    var singularOrPlural: String {
        return moreThanOneNoteSelected ? "notes" : "note"
    }
    
    @objc func openNewNote() {
        let note = noteService.createNote(with: nil)
        openNote(note)
    }
    
    func openNote(_ note: Note) {
        let noteController = NoteViewController(note: note, noteService: noteService)
        navigationController?.pushViewController(noteController, animated: true)
    }
    
    func deleteNote(_ note: Note) {
        noteService.deleteNote(note: note)
    }
    
    @objc func sendMultipleNotes() {
        guard atLeastOneNoteSelected else { return }
        noteService.sendNotes(selectedNotes, viewController: self)
    }
    
    @objc func deleteSelectedNotes() {
        guard atLeastOneNoteSelected else { return }
        
        let thisOrThese   = moreThanOneNoteSelected ? "these" : "this"
        let numberOfNotes = moreThanOneNoteSelected ? "\(numberOfSelectedRows) " : ""
        let message       = "Deleting \(thisOrThese) \(numberOfNotes)\(singularOrPlural) cannot be undone"
        
        promptToContinue(withMessage: message, onYesText: "Delete", onNoText: "Cancel") { [weak self] in
            guard let self = self else { return }
            
            self.noteService.deleteNotes(self.selectedNotes)
            self.setEditing(false, animated: true)
            self.getNotes()
        }
    }
    
    @objc func getNotes() {
        notes = noteService.getAllNotes(containing: searchBar.text)
        tableView.reloadData()
    }
    
    @objc func refreshCells() {
        tableView.reloadData()
    }
}

// MARK:- Select all / deselect all
private extension NoteListViewController {
    var moreThanOneNoteSelected: Bool {
        return numberOfSelectedRows > 1
    }
    
    var zeroNotesSelected: Bool {
        return numberOfSelectedRows == 0
    }
    
    var numberOfSelectedRows: Int {
        return selectedIndices.count
    }
    
    var atLeastOneNoteSelected: Bool {
        return numberOfSelectedRows > 0
    }
    
    var selectedNotes: Set<Note> {
        return Set(selectedIndices.map { notes[$0.row] })
    }
    
    var selectedIndices: [IndexPath] {
        return tableView.indexPathsForSelectedRows ?? []
    }
    
    @objc func selectAllOrDeselectAllNotes() {
        guard isEditing else { return }
        
        if atLeastOneNoteSelected {
            tableView.deselectAllRows()
        } else {
            tableView.selectAllRows()
        }
    }
}

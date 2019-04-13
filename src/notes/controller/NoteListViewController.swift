//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteListViewController: UITableViewController {
    private var searchController: UISearchController!
    private var table: UITableView!
    private var addButtomItem: UIBarButtonItem!
    private var trashButton: UIBarButtonItem!
    private var spacer: UIBarButtonItem!
    private var shareButton: UIBarButtonItem!
    private var noteService: NoteService!
    private var selectedNotes: Set<Note>!
    private var notes: [Note]!
    private var isSearching = false {
        
        // Cannot search and add at same time
        didSet {
            addButtomItem.isEnabled = !isSearching
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        
        // Configure search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        
        // Configure table view
        table = UITableView()
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        table.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        view.addAndPinSubview(table)
        
        // Configure nav bar
        addButtomItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewNote))
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = addButtomItem
        editButtonItem.title = "Select"
    
        // Configure tool bar
        spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedNotes))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendMultipleNotes))
        
        
        shareButton.isEnabled = false
        trashButton.isEnabled = false
        trashButton.tintColor = .red
        toolbarItems = [shareButton, spacer, trashButton]
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    init() {
        super.init(style: .plain)
        
        noteService = NoteService.instance
        selectedNotes = Set<Note>()
        notes = [Note]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Callback for every update to search bar
extension NoteListViewController: UISearchResultsUpdating {
    
    /// Searches for notes after each key tap while searching
    func updateSearchResults(for searchController: UISearchController) {
        getNotes()
    }
}

/// Callbacks for search bar events
extension NoteListViewController: UISearchBarDelegate {
    
    /// User started typing in search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    /// User stopped typing in search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    /// Always refresh the page after cancelling search
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        getNotes()
    }
}

/// TableView callbacks
extension NoteListViewController {
    
    /// Toggle button's isEnabled flag based off is isEditing
    /// If we are editing, we should only be able to delete
    /// selected items. This is with the condition that we are
    /// NOT in searching mode.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            editButtonItem.title = "Done"
            addButtomItem.isEnabled = false
            
        } else {
            editButtonItem.title = "Select"
            trashButton.isEnabled = false
            shareButton.isEnabled = false
            
            // No adding while searching
            if !isSearching {
                addButtomItem.isEnabled = true
            }
        }
    }
    
    /// Removes a note from set of selected notes
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        
        selectedNotes.remove(note)
        
        if selectedNotes.isEmpty {
            trashButton.isEnabled = false
            shareButton.isEnabled = false
        }
    }
    
    /// Handle event where a cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        
        if isEditing {
            selectedNotes.insert(note)
            trashButton.isEnabled = true
            shareButton.isEnabled = true
            
        } else {
            openNote(note)
        }
    }
    
    /// Number of cells to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    /// Initializes a cell in table view (called on each cell)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let note = notes[indexPath.row]
        
        guard let textLabel = cell.textLabel else { return cell }
        
        textLabel.font = textLabel.font.bolded
        textLabel.text = note.title
        
        var detail = ""
        
        if let date = note.lastEditedDate?.formatted {
            detail += "\(date)\n"
        }
        
        detail += note.body?.firstLine.truncated(after: 30) ?? ""
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = detail
        cell.detailTextLabel?.textColor = .gray
        
        return cell
    }
    
    /// Deletes a note
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let note = notes.remove(at: indexPath.row)
        
        deleteNote(note)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

/// CRUD functions and other auxiliary functionality
extension NoteListViewController {
    
    /// Prompt user to enter title, then create and open new note
    @objc private func openNewNote() {
        let message = "Give your note a name"
        let placeholder = "Untitled"
        
        func onConfirm(title: String?) {
            let note = noteService.createNote(with: title)
            openNote(note)
        }
        
        promptForText(withMessage: message,
                      placeholder: placeholder,
                      onConfirm: onConfirm,
                      onCancel: nil)
    }
    
    /// Opens note via NoteController
    private func openNote(_ note: Note) {
        let noteController = NoteController(note: note, noteService: noteService)
        
        navigationController?.pushViewController(noteController, animated: true)
    }
    
    /// Deletes note from database
    private func deleteNote(_ note: Note) {
        noteService.deleteNote(note: note)
    }
    
    /// Send multiple notes
    @objc private func sendMultipleNotes() {
        guard !selectedNotes.isEmpty else { return }
        
        noteService.sendNotes(selectedNotes, viewController: self)
    }
    
    /// Deletes all selected notes from database
    @objc private func deleteSelectedNotes() {
        guard !selectedNotes.isEmpty else { return }
        
        let message = "Delete \(selectedNotes.count) note(s)?"
        
        func onYes() {
            // NOTE: https://developer.apple.com/documentation/uikit/uitableview/1614960-deleterows
            // Animate the deletion. We will need an auxiliary structure
            // that maps selected notes to their indices. Perhaps turn
            // selected notes into a dictionary, and wherever selectedNotes
            // is used, just get the key set.
            noteService.deleteNotes(selectedNotes) { [weak self] in
                guard let sself = self else { return }
                
                sself.setEditing(false, animated: true)
                sself.selectedNotes.removeAll()
                sself.getNotes()
            }
        }
        
        promptYesOrNo(withMessage: message, onYes: onYes, onNo: nil)
    }
    
    /// Refresh table with newest data from DB
    private func getNotes() {
        notes = noteService.notes
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            notes = notes.filter { note in
                return note.contains(text: searchText)
            }
        }
        
        tableView.reloadData()
    }
}

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
    
        // Configure tool bar
        spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedNotes))
        trashButton.isEnabled = false
        trashButton.tintColor = .red
        toolbarItems = [spacer, trashButton]
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
        
        noteService = NoteService()
        selectedNotes = Set<Note>()
        notes = [Note]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteListViewController: UISearchResultsUpdating {
    
    /// Searches for notes after each key tap while searching
    func updateSearchResults(for searchController: UISearchController) {
        getNotes()
    }
}

extension NoteListViewController: UISearchBarDelegate {
    
    /// Sets searching flag to true to indicate
    /// that we are in the searching state
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    /// Sets searching flag to true to indicate
    /// that we not are in the searching state
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

extension NoteListViewController {
    
    /// Toggle button's isEnabled flag based off is isEditing
    /// If we are editing, we should only be able to delete
    /// selected items. This is with the condition that we are
    /// NOT in searching mode.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            addButtomItem.isEnabled = false
        } else {
            trashButton.isEnabled = false
            
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
        }
    }
    
    /// Handle event where a cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        
        if isEditing {
            selectedNotes.insert(note)
            trashButton.isEnabled = true
            
        } else {
            openNote(note)
        }
    }
    
    /// Number of cells to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    /// Initializes a (each) cell in table view
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
    
    /// Deletes a cell from tablew view and persistent storage
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let note = notes.remove(at: indexPath.row)
        
        deleteNote(note)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

/// Custom functions
extension NoteListViewController {
    
    /// Builds and displays a prompt for the user
    /// to enter the title / name of the newly created note
    @objc private func openNewNote() {
        let message = "Give your not a name"
        let placeholder = "Untitled"
        
        func onConfirm(title: String?) {
            if let note = createNote(with: title) {
                openNote(note)
            }
        }
        
        promptForText(withMessage: message, placeholder: placeholder, onConfirm: onConfirm)
    }
    
    /// Creates instance of NoteController and presents it
    /// with note that corresponds to the cell that was tapped
    private func openNote(_ note: Note) {
        let noteController = NoteController(note: note, noteService: noteService)
        
        navigationController?.pushViewController(noteController, animated: true)
    }
    
    /// Creates a new note with a specified title
    private func createNote(with title: String?) -> Note? {
        return noteService.noteFactory.createNote(with: title)
    }
    
    /// Deletes note from database
    private func deleteNote(_ note: Note) {
        noteService.noteFactory.deleteNote(note: note)
    }
    
    /// Deletes all selected notes from database
    @objc private func deleteSelectedNotes() {
        guard !selectedNotes.isEmpty else { return }
        
        let message = "Are you sure you would like to delete \(selectedNotes.count) note(s)"
        
        func onYes() {
            noteService.noteFactory.deleteNotes(selectedNotes) { [weak self] in
                guard let sself = self else { return }
                
                sself.setEditing(false, animated: true)
                sself.selectedNotes.removeAll()
                sself.getNotes()
            }
        }
        
        promptYesOrNo(withMessage: message, onYes: onYes)
    }
    
    /// Gets the updated list of notes from the note service,
    /// refreshes the table and performs any callbacks
    private func getNotes() {
        notes = noteService.noteFactory.notes
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            notes = notes.filter { note in
                return note.contains(text: searchText)
            }
        }
        
        tableView.reloadData()
    }
}

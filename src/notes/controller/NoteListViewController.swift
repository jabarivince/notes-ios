//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

// https://stackoverflow.com/questions/29664315/how-to-implement-uisearchcontroller-in-uitableview-swift
// https://www.raywenderlich.com/472-uisearchcontroller-tutorial-getting-started
// https://shrikar.com/swift-ios-tutorial-uisearchbar-and-uisearchbardelegate/

import Foundation
import UIKit

/// Main view controller that has the list (table view)
/// of cells thar correspond to the notes that are on the device.
class NoteListViewController: UITableViewController {
    
    // Search / table view items
    private let searchController = UISearchController(searchResultsController: nil)
    private let refresh = UIRefreshControl()
    private let table = UITableView()
    
    // State items
    private let noteService = NoteService()
    private var selectedNotes = Set<Note>()
    private var notes = [Note]()
    
    // Keeps track of state of search bar.
    // That way, we to enable / disable
    // other subviews automatically via didSet
    private var isSearching = false {
        didSet {
            if isSearching {
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        
        // Configur search bar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        
        // Configure table view
        tableView.refreshControl = refresh
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        table.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        view.addAndPinSubview(table)
        
        // Configure nav bar
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewNote))
        refresh.addTarget(self, action: #selector(refreshNoteList), for: .valueChanged)
    
        // Configure tool bar
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(delectAllSelectedNotes))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
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
}

extension NoteListViewController: UISearchResultsUpdating {
    
    /// Searches for notes after each key tap
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
    
    /// After cancelling, always refresh the page
    /// and hide the cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        getNotes {
            searchBar.showsCancelButton = false
        }
    }
}

extension NoteListViewController {
    
    /// Removes a note from set of selected notes
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        
        selectedNotes.remove(note)
    }
    
    /// If we are in editing mode, we add the tapped note
    /// to the set of notes that will are selected. Otherwise,
    /// we open the note that was tapped for editing.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            let note = notes[indexPath.row]
            
            selectedNotes.insert(note)
            
        } else {
            openNote(notes[indexPath.row])
        }
    }
    
    /// Boilerplate to let TablewView know
    /// how many cells it must display on screen
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    /// Initializes a (each) cell in table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let note = notes[indexPath.row]
        
        guard let textLabel = cell.textLabel else { return cell }
        
        textLabel.font = .boldSystemFont(ofSize: textLabel.font.pointSize)
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
    @objc private func openNewNote(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Give your note a name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Untitled"
        }
        
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self, weak alert] _ in
            let title = alert?.textFields?[0].text
            
            if let note = self?.createNote(with: title) {
                self?.openNote(note)
            }
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .default) { [weak alert] _ in
            alert?.dismiss(animated: true, completion: nil)
        }
        
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Refreshes the list of notes and then
    /// hides the loading spinner
    @objc private func refreshNoteList() {
        
        // Get the notes, then after one second hide the loading
        // spinner. The delay fixes jittery synchronization issues
        getNotes { [weak self] in
            if self?.tableView.refreshControl?.isRefreshing == true {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    /// Creates instance of NoteController and presents it
    /// with note that corresponds to the cell that was tapped
    private func openNote(_ note: Note) {
        let noteController = NoteController(note: note, noteService: noteService)
        
        self.navigationController?.pushViewController(noteController, animated: true)
    }
    
    /// Creates a new note with a specified title
    private func createNote(with title: String?) -> Note? {
        return noteService.noteFactory.createNote(with: title)
    }
    
    /// Deletes note from database
    private func deleteNote(_ note: Note) {
        noteService.noteFactory.deleteNote(note: note)
    }
    
    /// Delects all selected notes from database
    @objc private func delectAllSelectedNotes() {
        noteService.noteFactory.deleteNotes(selectedNotes) { [weak self] in
            guard let sself = self else { return }
            
            sself.isEditing = false
            sself.selectedNotes.removeAll()
            sself.getNotes()
        }
    }
    
    /// Gets the updated list of notes from the note service,
    /// refreshes the table and performs any callbacks
    private func getNotes(completion: (() -> Void)? = nil) {
        notes = noteService.noteFactory.notes
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            notes = notes.filter { note in
                return note.contains(text: searchText)
            }
        }
        
        tableView.reloadData()
        
        if let completion = completion {
            completion()
        }
    }
}

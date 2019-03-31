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
    private let searchController = UISearchController(searchResultsController: nil)
    private let refresh = UIRefreshControl()
    private let table = UITableView()
    private let noteService = NoteService.singleton
    private var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        
        // TableView won't add empty cells if there is a footer
        tableView.refreshControl = refresh
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.allowsSelectionDuringEditing = true
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        
        table.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        view.addAndPinSubview(table)
        
        // Set callbacks for button taps
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewNote))
        refresh.addTarget(self, action: #selector(refreshNoteList), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.prefersLargeTitles = true
        getNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
}

extension NoteListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        getNotes()
    }
}

extension NoteListViewController: UISearchBarDelegate {
    
    /// Override cancel button on-click handler
    /// because it acts up when popping the NoteController
    /// of the navigation stack.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        getNotes {
            searchBar.showsCancelButton = false
        }
    }
}

extension NoteListViewController {
    
    /// Callback for tapping a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openNote(notes[indexPath.row])
    }
    
    /// Boilerplate to let TablewView know
    /// how many cells it must display on screen
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    /// Function that gets call on each cell that
    /// actually  initializes thew view of each cell
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
    
    /// Enables the deletion function for each cell.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let note = notes.remove(at: indexPath.row)
        
        noteService.noteFactory.deleteNote(note: note)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

/// Functions associated with naming the note prior
/// to it being passes to the NoteViewController.
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
        
            if let note = self?.noteService.noteFactory.createNote(with: title) {
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
}

/// Callbacks associated with button taps and gestures.
extension NoteListViewController {
    @objc func refreshNoteList() {
        
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
    /// with note that corresponds  to the cell that was tapped
    private func openNote(_ note: Note) {
        let noteController = NoteController(note: note, noteService: noteService)
        
        self.navigationController?.pushViewController(noteController, animated: true)
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

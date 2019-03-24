//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

/// Main view controller that has the list
/// (table view) of cells thar correspond
/// to the notes that are on the device.
class MainViewController: UITableViewController {
    let refresh = UIRefreshControl()
    let table = UITableView()
    
    let noteFactory = NoteService.noteFactory
    var notes: [Note] = []
    
    /// Initialize the view for the first time.
    /// This only gets called once.
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refresh
        title = "Notes"
        
        // Initialize the main table view
        table.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        table.dataSource = self
        view.addSubview(table)
        
        // Table view should occupy full screen
        // TODO: Figure ou unsatisiable constraints error on startup
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            table.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            table.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        // Set callbacks for button taps
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewNote))
        refresh.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
    }
    
    /// Updates the view. This gets called every time
    /// this view becomes active. This occurs on first
    /// load, returning to the app, or returning from
    /// editting a note.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        getNotes()
    }
}

/// TableView callbacks
extension MainViewController {
    
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
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        
        let note = notes[indexPath.row]
        
        guard let textLabel = cell.textLabel else { return cell }
        
        // Style / font setup
        textLabel.font = UIFont.boldSystemFont(ofSize: textLabel.font.pointSize)
        textLabel.text = note.title
        cell.detailTextLabel?.text = note.body
        
        return cell
    }
    
    /// Enables the deletion function for each cell.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let note = notes.remove(at: indexPath.row)
            noteFactory.deleteNote(note: note)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}

/// Functions associated with naming the
/// note prior to it being passes to the
/// Note view controller.
extension MainViewController {
    
    /// Builds and displays a prompt for the user
    /// to enter the title / name of the newly created note
    @objc private func openNewNote(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Give your note a name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            // dynamicall name unamed notes
            // TODO: Untitled, Untitled (1), Untitled (2), ...
            textField.placeholder = "Untitled"
        }
        
        // Callback for "ok" tapped
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self, weak alert] _ in
            var title = alert?.textFields?[0].text ?? ""
            
            if title == "" {
                title = "Untitled"
            }
            
            if let note = self?.noteFactory.createNote(title: title) {
               self?.openNote(note)
            }
        }
        
        // Callback for "cancel" tapped
        let cancel = UIAlertAction(title: "cancel", style: .default) { [weak alert] _ in
            alert?.dismiss(animated: true, completion: nil)
        }
        
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        // Show alert
        self.present(alert, animated: true, completion: nil)
    }
}

/// Callbacks associated with button taps and gestures.
extension MainViewController {
    @objc func refresh(sender: AnyObject) {
        
        // Get the notes, then after one
        // second hide the loading spinner.
        // The delay fixes jittery synchronization issues
        getNotes { [weak self] in
            if self?.tableView.refreshControl?.isRefreshing == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    /// Creates instance of NoteController
    /// and presents it with note that corresponds
    /// to the cell that was tapped
    private func openNote(_ note: Note) {
        let noteController = NoteController(note: note)
        
        self.navigationController?.pushViewController(noteController, animated: true)
    }
    
    /// Gets the updated list of notes from the note service,
    /// refreshes the table and performs any callbacks
    private func getNotes(completion: (() -> Void)? = nil) {
        notes = noteFactory.notes
        
        tableView.reloadData()
        
        if let completion = completion {
            completion()
        }
    }
}

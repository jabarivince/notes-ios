//
//  ShareNoteListViewController.swift
//  notesShare
//
//  Created by jabari on 5/11/19.
//  Copyright © 2019 jabari. All rights reserved.
//
    
import UIKit
import notesServices

protocol ShareNoteListViewControllerDelegate: class {
    func noteSelected(_ note: Note?)
}

class ShareNoteListViewController: UITableViewController {
    weak var delegate: ShareNoteListViewControllerDelegate?
    let cellId = "cellReuseIdentifier"
    
    var data: [Note] = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        setupCreateNoteButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObservers()
        refreshNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeObservers()
    }
}

// MARK:- UITableViewController
extension ShareNoteListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.noteSelected(data[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = data[indexPath.row].title
        return cell
    }
}

private extension ShareNoteListViewController {
    func addObservers() {
        respondTo(NSNotification.Name.NSExtensionHostDidBecomeActive, with: #selector(refreshNotes))
    }
    
    func setupCreateNoteButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(newNoteSelected))
    }
    
    @objc func newNoteSelected() {
        delegate?.noteSelected(nil)
    }
    
    @objc func refreshNotes() {
        data = NoteService.shared.getAllNotes()
        tableView.reloadData()
    }
}

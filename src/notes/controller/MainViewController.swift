//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    let refresh = UIRefreshControl()
    let table = UITableView()
    
    lazy var notes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refresh
        title = "Notes"
        
        table.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        table.dataSource = self
        view.addSubview(table)
        
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            table.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            table.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewNote))
        refresh.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        getNotes()
    }
}

extension MainViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        
        openNote(note)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        
        let note = notes[indexPath.row]
        
        guard let textLabel = cell.textLabel else { return cell }
        
        textLabel.font = UIFont.boldSystemFont(ofSize: textLabel.font.pointSize)
        textLabel.text = note.title ?? "Untitled note*"
        cell.detailTextLabel?.text = note.body
        
        return cell
    }
}

extension MainViewController {
    @objc func refresh(sender: AnyObject) {
        getNotes { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func openNewNote(_ sender: UIBarButtonItem) {
        openNote(nil)
    }
    
    private func openNote(_ note: Note?) {
        let noteController = NoteController(note: note)
        
        self.navigationController?.pushViewController(noteController, animated: true)
    }
    
    private func getNotes(completion: (() -> Void)? = nil) {
        notes = NoteService.notes
        
        // TODO - Figure out how to update the table view
        // so that the table shoes the updated list of notes
        
        print("FETCHING NOTES")
        
        tableView.reloadData()
        
        if let completion = completion {
            completion()
        }
    }
}

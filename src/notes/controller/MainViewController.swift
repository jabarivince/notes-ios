//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    let table = UITableView()
    lazy var notes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotes()
        
        title = "Notes"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewNote))
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        table.dataSource = self
        
        view.addSubview(table)
        
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            table.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            table.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        getNotes()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
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
        
        let fontSize = textLabel.font.pointSize
        
        textLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        textLabel.text = note.title ?? "Untitled note*"
        
        cell.detailTextLabel?.text = note.body
        
        return cell
    }
}

extension MainViewController {
    @objc private func openNewNote(_ sender: UIBarButtonItem) {
        openNote(nil)
    }
    
    private func openNote(_ note: Note?) {
        let noteController = NoteController(note: note)
        
        self.navigationController?.pushViewController(noteController, animated: true)
    }
    
    private func getNotes() {
        notes = NoteService.notes
        
        print(notes)
    }
}

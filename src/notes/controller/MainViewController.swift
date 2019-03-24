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
    
    let noteService = NoteService.noteService
    
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let note = notes.remove(at: indexPath.row)
            noteService.deleteNote(note: note)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}

extension MainViewController {
    @objc func refresh(sender: AnyObject) {
        refreshControl?.endRefreshing()
    }
    
    @objc private func openNewNote(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Give your note a name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Untitled"
        }
        
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self, weak alert] _ in
            var title = alert?.textFields?[0].text ?? ""
            
            if title == "" {
                title = "Untitled"
            }
            
            if let note = self?.noteService.newNote(title: title) {
               self?.openNote(note)
            }
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .default) { [weak alert] _ in
            alert?.dismiss(animated: true, completion: nil)
        }
        
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openNote(_ note: Note) {
        let noteController = NoteController(note: note)
        
        self.navigationController?.pushViewController(noteController, animated: true)
    }
    
    private func getNotes(completion: (() -> Void)? = nil) {
        notes = noteService.notes

        tableView.reloadData()
        
        if let completion = completion {
            completion()
        }
    }
}

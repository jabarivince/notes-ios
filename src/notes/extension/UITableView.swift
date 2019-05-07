//
//  UITableView.swift
//  notes
//
//  Created by jabari on 5/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

extension UITableView {
    func deselectAllRows() {
        guard let selectedItems = indexPathsForSelectedRows else { return }
        
        for indexPath in selectedItems {
            _ = delegate?.tableView?(self, willDeselectRowAt: indexPath)
            deselectRow(at: indexPath, animated: false)
            delegate?.tableView?(self, didDeselectRowAt: indexPath)
        }
    }
    
    func selectAllRows() {
        for section in 0..<numberOfSections {
            for row in 0..<numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                _ = delegate?.tableView?(self, willSelectRowAt: indexPath)
                selectRow(at: indexPath, animated: false, scrollPosition: .none)
                delegate?.tableView?(self, didSelectRowAt: indexPath)
            }
        }
    }
}

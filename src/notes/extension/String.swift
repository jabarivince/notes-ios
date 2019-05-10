//
//  String.swift
//  notes
//
//  Created by jabari on 3/26/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

extension String {
    var firstLine: String {
        return components(separatedBy: "\n")[0]
    }
    
    func truncated(after length: Int, trailedWith trailing: String = "…") -> String {
        return (count > length) ? prefix(length) + trailing : self
    }
}

extension String {
    var asNSString: NSString {
        return self as NSString
    }
    
    static func format(strings: [String],
                       boldFont: UIFont = .boldSystemFont(ofSize: 14),
                       boldColor: UIColor = .blue,
                       inString string: String,
                       font: UIFont = .systemFont(ofSize: 14),
                       color: UIColor = .black) -> NSAttributedString {
        
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        
        let boldFontAttribute = [
            NSAttributedString.Key.font: boldFont,
            NSAttributedString.Key.foregroundColor: boldColor
        ]
        
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        
        for bold in strings {
            attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: bold))
        }
        
        return attributedString
    }
}

//
//  ViewController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    private var taps = 0 {
        didSet {
            label.text = "\(taps)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taps = 0
    }
    
    @IBAction func onTap(_ sender: UIButton) {
        taps += 1
    }
}


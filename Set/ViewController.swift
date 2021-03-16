//
//  ViewController.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import UIKit

class ViewController: UIViewController {
    
    // Properties
    let game = SetGame()
    
    @IBOutlet var openCardsButtons: [UIButton]!
    
    
    
    
    
    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dealButtonPressed(_ sender: UIButton) {
        // TODO
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
    }
    
}


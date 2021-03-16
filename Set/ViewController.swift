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
        // My additions for this function:
        setViewForGameBeginning()
    }
    
    @IBAction func dealButtonPressed(_ sender: UIButton) {
        // TODO
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
    }
    
    
    @IBAction func touchCard(_ sender: UIButton) {
    }
    
    
    // Private Methods
    
    private func updateViewFromModel() {
        // TODO
    }
    
    private func setViewForGameBeginning() {
        //
        for openCard in openCardsButtons {
            openCard.setAttributedTitle(nil, for: UIControl.State.normal)
            openCard.setTitle(nil, for: UIControl.State.normal)
        }
    
        for i in 12..<openCardsButtons.count {
            openCardsButtons[i].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        }
    }
}

enum SetShapes {
    // ▲, ●, ■
    case circle
    case triangle
    case square
}

enum fillingOptions {
    case full
    case striped
    case empty
}

enum color {
    case purple
    case green
    case pink
}

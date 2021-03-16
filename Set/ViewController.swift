//
//  ViewController.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import UIKit

class ViewController: UIViewController {
    
    // Properties
    
    let shapesDict = [1: "▲", 2: "●", 3: "■"]
    let colorDict = [1: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), 2: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), 3: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    let game = SetGame()
    
    @IBOutlet var cardsButtons: [UIButton]!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var gameCardsOnView = [SetCard?](repeating: nil, count: 24)
    
    
    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromModel()
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
        
        // make sure the view recognize all open cards from the model.
        for index in game.openCards.indices {
            if !gameCardsOnView.contains(game.openCards[index]) {
                addGameCardToView(gameCard: game.openCards[index])
            }
        }
        
        // Go over all cardButtons and update the info that they present
        for index in gameCardsOnView.indices {
            if let card = gameCardsOnView[index] {
                // if the current element in gameCardsOnView isn't nil
                cardsButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cardsButtons[index].setAttributedTitle(attriubtedStringForCard(card: card), for: UIControl.State.normal)
            } else {
                cardsButtons[index].setAttributedTitle(nil, for: UIControl.State.normal)
                cardsButtons[index].setTitle(nil, for: UIControl.State.normal)
                cardsButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            }
        }
    }
        
    // TODO
    private func attriubtedStringForCard(card: SetCard) -> NSAttributedString {
                 
        let alpha: CGFloat
        if card.filling == 3 {
            alpha = 0.15
        } else {
            alpha = 1.0
        }
        
        if let color = colorDict[card.color] {
            let attributes: [NSAttributedString.Key: Any] = [
                .strokeWidth: 5.0 * pow(-1, card.filling),
                .strokeColor: color,
                .foregroundColor:  color.withAlphaComponent(alpha)
                ]
            if let shape = shapesDict[card.shapeType] {
                var string = ""
                for _ in 0..<card.shapesNum {
                    string += shape + " "
                }
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
        // TODO - comment that this is the other side of optional
        return NSAttributedString(string: "")
    }
    
    // TODO
    private func addGameCardToView(gameCard: SetCard) {
        for index in gameCardsOnView.indices {
            if gameCardsOnView[index] == nil {
                gameCardsOnView[index] = gameCard
                break
            }
        }
    }
}

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
    var game = SetGame()
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var scoreLabel: UILabel!

    // each index of this array represents a cardButton, and each value is a reference to a SetCard instance (or nil) linked to it
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
    
    @IBAction func touchCard(_ sender: UIButton) { // todo = start here on wednesday.
        if let index = cardButtons.firstIndex(of: sender){
            game.chooseCard(at: index)
            updateViewFromModel()
        } else {
            
        }
    }
    
    // Private Methods
    
    private func updateViewFromModel() {
        
        // Make sure that the view only holds the game's open cards.
        for index in gameCardsOnView.indices {
            if let card = gameCardsOnView[index] {
                if !game.openCards.contains(card) {
                    // if this card is no longer in the game then we don't need a reference to it
                    gameCardsOnView[index] = nil
                }
            }// else: gameCardsOnView[index] = nil
        }
        
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
                cardButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cardButtons[index].setAttributedTitle(attriubtedStringForCard(card: card), for: UIControl.State.normal)
            } else {
                cardButtons[index].setAttributedTitle(nil, for: UIControl.State.normal)
                cardButtons[index].setTitle(nil, for: UIControl.State.normal)
                cardButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            }
        }
        // Mark selected cards
        // todo 
    }
        
    // TODO
    private func attriubtedStringForCard(card: SetCard) -> NSAttributedString {
        
        // alpha is 0.15 for striped shapes, 1.0 otherwise
        let alpha: CGFloat = card.filling == 3 ? 0.15: 1.0
        
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
        // todo - comment about this.
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

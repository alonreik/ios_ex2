//
//  ViewController.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import UIKit

class ViewController: UIViewController {
    
    /* Properties */

    var boardIsFull: Bool {
        get {
            return cardButtonsMapper.filter({$0 != nil}).count == cardButtons.count // closure
        }
    }
    
    let shapesDict = [1: "▲", 2: "●", 3: "■"]
    let colorDict = [1: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), 2: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), 3: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    // filling dict: [1: full, 2: outline, 3: striped]
    
    var game: SetGame = SetGame()
    var gameState = SetGameState.noMatchIsMarked
    
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var scoreLabel: UILabel!

    // each index of this array represents a cardButton, and each value is a reference to a SetCard instance (or nil) linked to it
    lazy var cardButtonsMapper = [SetCard?](repeating: nil, count: cardButtons.count)
    

    /* Methods */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetUp()
    }
    
    @IBAction func dealButtonPressed(_ sender: UIButton) {
        if !boardIsFull {
            game.drawThreeCards()
            if gameState == SetGameState.noMatchIsMarked {
                initialViewSetUp()
            } else {
                // todo - deal later
                print("i am here")
            }
        }
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let index = cardButtons.firstIndex(of: sender){
            if let openCard = cardButtonsMapper[index] {
                game.chooseCard(chosenCard: openCard)
                updateViewAfterTurn()
//                updateViewFromModel()
            } else {
                print("The mapping between game.openCards and the UI cardButton is wrong.")
            }
        } else { // shouldn't be reached, in case the cardButtons weren't configured correclty
            return
        }
    }
    
    // Private Methods
    
    private func updateMapperWithOpenCards() {
        for index in game.openCards.indices {
            if !cardButtonsMapper.contains(game.openCards[index]) {
                addGameCardToView(gameCard: game.openCards[index])
            }
        }
    }
    
    
    // update mapper from open cards
    private func initialViewSetUp() {
        
        updateMapperWithOpenCards()
        updateViewFromModel()
        // make sure the view recognize all open cards from the model.
//        for index in game.openCards.indices {
//            if !cardButtonsMapper.contains(game.openCards[index]) {
//                addGameCardToView(gameCard: game.openCards[index])
//            }
//        }
//        // Go over all cardButtons and update the info that they present
//        for index in cardButtonsMapper.indices {
//            if let card = cardButtonsMapper[index] {
//                // if the current element in gameCardsOnView isn't nil
//                cardButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//                cardButtons[index].setAttributedTitle(attriubtedStringForCard(card: card), for: UIControl.State.normal)
//            } else {
//                cardButtons[index].setAttributedTitle(nil, for: UIControl.State.normal)
//                cardButtons[index].setTitle(nil, for: UIControl.State.normal)
//                cardButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
//            }
//        }
    }
    
    private func updateViewAfterTurn() {
        // if SetCards mapped by cardButtonsMapper are no longer in the game(model) - mark their spot as free (nil)
        for index in cardButtonsMapper.indices {
            if let card = cardButtonsMapper[index] {
                if !game.openCards.contains(card) {
                    // if this card is no longer in the game then we don't need a reference to it
                    cardButtonsMapper[index] = nil
                }
            }// else: gameCardsOnView[index] was already nil
        }
        
        // make sure the view recognize all open cards from the model.
        for index in game.openCards.indices {
            if !cardButtonsMapper.contains(game.openCards[index]) {
                addGameCardToView(gameCard: game.openCards[index])
            }
        }
    }

    private func updateViewAfterDeal() {
    
    }
    
    private func updateViewFromModel() {

        // make sure the view recognize all open cards from the model.
//        for index in game.openCards.indices {
//            if !cardButtonsMapper.contains(game.openCards[index]) {
//                addGameCardToView(gameCard: game.openCards[index])
//            }
//        }
        
        // Go over all cardButtons and update the info that they present
        for index in cardButtonsMapper.indices {
            if let card = cardButtonsMapper[index] {
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
        
        // alpha is 0.15 for striped shapes (filling == 3), 1.0 for other fillings
        let alpha: CGFloat = card.filling == 3 ? 0.15: 1.0
        
        if let color = colorDict[card.color] {
            let attributes: [NSAttributedString.Key: Any] = [
                // .strokeWidth should be positive only for outlined shapes (filling == 2), otherwise should be negative
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
        for index in cardButtonsMapper.indices {
            if cardButtonsMapper[index] == nil {
                cardButtonsMapper[index] = gameCard
                break
            }
        }
    }
}

enum SetGameState {
    case aMatchIsMarked
    case noMatchIsMarked
}

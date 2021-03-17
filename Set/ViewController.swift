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
    var matchesCounter = 0

    var aMatchIsMarked: Bool {
        get {
            return matchesCounter < game.matches.count
        }
    }
    
    
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
            if !aMatchIsMarked {
                initialViewSetUp()
            } else {
                removeMatchedCardsFromMapper()
            }
        }
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let index = cardButtons.firstIndex(of: sender){
            if let chosenCard = cardButtonsMapper[index] {
                if aMatchIsMarked {
                    matchesCounter += 1
                    
                }
                game.chooseCard(chosenCard: chosenCard)
                updateViewFromModel()
            } else {
                print("The mapping between game.openCards and the UI cardButton is wrong.")
            }
        } else { // shouldn't be reached, in case the cardButtons weren't configured correclty
            return
        }
    }
    
    /* Private Methods */
    
    private func addNewOpenCardsToMapper() {
        for index in game.openCards.indices {
            if !cardButtonsMapper.contains(game.openCards[index]) {
                addGameCardToButtonsArray(gameCard: game.openCards[index])
            }
        }
    }
    
    private func findOpenCardNotInMapper() -> SetCard? {
        for index in game.openCards.indices {
            if !cardButtonsMapper.contains(game.openCards[index]) {
                return game.openCards[index]
            }
        }
        return nil
    }
    
    /* Makes sure that mapper only hold references to open cards in the game (model)  */
    private func removeMatchedCardsFromMapper() {
        // if SetCards mapped by cardButtonsMapper are no longer in the game(model) - mark their spot as free (nil)
        for index in cardButtonsMapper.indices {
            if let card = cardButtonsMapper[index] {
                if !game.openCards.contains(card) {
                    // if this card is no longer in the game then we don't need a reference to it
                    cardButtonsMapper[index] = findOpenCardNotInMapper()
                }
            }// else: gameCardsOnView[index] was already nil
        }
    }
    
    private func initialViewSetUp() {
        addNewOpenCardsToMapper()
        updateViewFromModel()
    }


    private func updateViewAfterDeal() {
    
    }
    
    private func updateViewFromModel() {
        
        // Go over all cardButtons and update the info that they present
        for index in cardButtonsMapper.indices {
            if let card = cardButtonsMapper[index] {
                cardButtons[index].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cardButtons[index].setAttributedTitle(attriubtedStringForCard(card: card), for: UIControl.State.normal)
                cardButtons[index].layer.borderColor = game.selectedCards.contains(card) ? #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1): #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cardButtons[index].layer.borderWidth = game.selectedCards.contains(card) ? 3.0: 0.0
                
                if let lastMatch = game.matches.last {
                    cardButtons[index].layer.borderColor = lastMatch.contains(card) ?#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1): #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                } // if lastMatch is nil then there weren't any matches in the game (so no border coloring is needed).
                
            } else { // cardButtonsMapper[index] is nil (the button should be covered).
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
    private func addGameCardToButtonsArray(gameCard: SetCard) {
        for index in cardButtonsMapper.indices {
            if cardButtonsMapper[index] == nil {
                cardButtonsMapper[index] = gameCard
                break
            }
        }
    }
}

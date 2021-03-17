//
//  ViewController.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import UIKit

class ViewController: UIViewController {
    
    /* -------
     Properties
     -------- */

    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet var cardButtons: [UIButton]!

    /* An array mapping between cardButtons (buttons in the UI; every index represents a button) to SetCard objects.
     (A nil value means that the button should be "empty") */
    lazy var cardButtonsMapper = [SetCard?](repeating: nil, count: cardButtons.count)
    // (I used lazy only so I could use the count of cardButtons)
    
    var boardIsFull: Bool {
        get {
            // is cardButtonsMapper "nil-free"?
            return cardButtonsMapper.filter({$0 != nil}).count == cardButtons.count
        }
    }
    
    let shapesDict = [1: "▲", 2: "●", 3: "■"]
    let colorDict = [1: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), 2: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), 3: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    // filling dict: [1: full, 2: outline, 3: striped]
    
    var game: SetGame = SetGame()
    
    // A "helper variable" used to check if a new match is presented on the view
    var matchesCounter = 0
    
    var aMatchIsMarked: Bool {
        get {
            return matchesCounter < game.matches.count
        }
    }
    
    /* -------
     Methods
     -------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetUp()
    }
    
    // 
    @IBAction func dealButtonPressed(_ sender: UIButton) {
        if aMatchIsMarked {
            matchesCounter += 1
            game.drawThreeCards()
            replaceMatchedCardsOnMapper() //
        }
        else if !boardIsFull {
            game.drawThreeCards()
            addNewOpenCardsToMapper()
        }
        updateViewFromMapper()
    }
    
    //
    @IBAction func newGamePressed(_ sender: UIButton) {
        cardButtonsMapper = [SetCard?](repeating: nil, count: cardButtons.count)
        game = SetGame()
        initialViewSetUp()
    }
    
    //
    @IBAction func touchCard(_ sender: UIButton) {
        if let index = cardButtons.firstIndex(of: sender){
    
            if let chosenCard = cardButtonsMapper[index] {
                
                if aMatchIsMarked { // then this is the 4th card selected after a match
                    matchesCounter += 1
                    game.chooseCard(chosenCard: chosenCard)
                    replaceMatchedCardsOnMapper()
                } else {
                    game.chooseCard(chosenCard: chosenCard)
                }
                updateViewFromMapper()
            } else { // cardButtonsMapper[index] = nil
                print("Pressed on a 'hidden' card.")
            }
        } else {
            print("Encountered an error. The UI included a button which isn't on cardButtons.")
        }
        
    }
    
    
    /* -------
     Private Methods
     -------- */
    
    //
    private func addNewOpenCardsToMapper() {
        for index in game.openCards.indices {
            if !cardButtonsMapper.contains(game.openCards[index]) {
                addGameCardToButtonsArray(gameCard: game.openCards[index])
            }
        }
    }
    
    
    /*
        Returns the first SetCard object that is in game.OpenCards but has yet appeared on the view.
        If all game.OpenCards are already on the view, Returns nil.
     */
    private func findMatchedCardReplacement() -> SetCard? {
        for index in game.openCards.indices {
            if !cardButtonsMapper.contains(game.openCards[index]) {
                return game.openCards[index]
            }
        }
        return nil
    }
    
    /* Makes sure that mapper only hold references to open cards in the game (model)  */
    private func replaceMatchedCardsOnMapper() {
        // if SetCards mapped by cardButtonsMapper are no longer in the game(model) - mark their spot as free (nil)
        for index in cardButtonsMapper.indices {
            if let card = cardButtonsMapper[index] {
                if !game.openCards.contains(card) {
                    // if this card is no longer in the game then we don't need a reference to it:
                    cardButtonsMapper[index] = findMatchedCardReplacement()
                } 
            }// else: gameCardsOnView[index] was already nil
        }
    }
    
    // TODO
    private func initialViewSetUp() {
        addNewOpenCardsToMapper()
        updateViewFromMapper()
    }

    // TODO
    private func updateViewFromMapper() {
        scoreLabel.text = "Score: \(game.score)"
        
        // Go over all cardButtons (using the careButtonsMapper) and update the info that they present
        for index in cardButtonsMapper.indices {
            let button = cardButtons[index]
            if let card = cardButtonsMapper[index] { // if a card is in that index
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                button.setAttributedTitle(attriubtedStringForCard(card: card), for: UIControl.State.normal)
                button.layer.borderColor = game.selectedCards.contains(card) ? #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1): #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                button.layer.borderWidth = game.selectedCards.contains(card) ? 3.0: 0.0
                
                if let lastMatch = game.matches.last { // if a matched card is in that index
                    button.layer.borderColor = lastMatch.contains(card) ?#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1): #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                } // if lastMatch is nil then there weren't any matches in the game (so no border coloring is needed).
                
            } else { // if nil is in that index (the button should be covered).
                button.setAttributedTitle(nil, for: UIControl.State.normal)
                button.setTitle(nil, for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                button.layer.borderWidth = 0.0
            }
        }
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

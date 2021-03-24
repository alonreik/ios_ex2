//
//  ViewController.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import UIKit

class ViewController: UIViewController {
    
    // The enemy turns' durations will be a generated randomly between the values below:
    let minWaitingDurationForEnemyTurn = 5.0
    let maxWaitingDurationForEnemyTurn = 20.0
    
    // The player will have the number of seconds listed below to find a match\set before his\her score will be damaged.
    let timeForPlayerToFindSet = 10.0

    // Shapes' "strokeWidth" should be positive only for outlined shapes.
    let strokeWidthForOutlineShapes = 5.0
    let strokeWidthForFilledShapes = -5.0
    
    // Cards with filling of type 3 (striped shapes) get different alpha values (for coloring) than other cards.
    let alphaForStripedShapes = 0.15
    let alphaForFullShapes = 1.0
    
    // When the time for a player to find a match elapses, his\her score is updated with the value below.
    let scoreTimePenalty = 10
    
    // The strings below are presented on the screen as the enemy's status according to the current score.
    let enemyLosingTitle = "📱😢" // presented if the enemy's score >= user's score.
    let enemyWinningTitle = "📱😂" // presented otherwise.
    
    /* -------
     Properties
     -------- */

    var gameTimer: Timer?
    var enemyTimer: Timer?
    
    @IBOutlet weak var userScoreLabel: UILabel!
    
    @IBOutlet weak var iphoneScoreLabel: UILabel!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    
    // iphoneStateLabel.text = userScore >= iphoneScore? 📱😢 : 📱😂
    // (if the enemy has higher score, it smiles. otherwise it weeps).
    @IBOutlet weak var iphoneStateLabel: UILabel!
    
    @IBOutlet var cardButtons: [UIButton]!

    var game: SetGame = SetGame()
    
    let shapesDict = [SetCard.Shape.typeOne: "▲", SetCard.Shape.typeTwo: "●", SetCard.Shape.typeThree: "■"]
    let colorDict = [SetCard.Color.typeOne: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), SetCard.Color.typeTwo: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), SetCard.Color.typeThree: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)]
    // filling dict: [1: full, 2: outline, 3: striped]
    
    /* An array mapping between cardButtons (buttons in the UI; every index represents a button)
     to SetCard objects. (A nil value means that the button should be "empty") */
    lazy var cardButtonsMapper = [SetCard?](repeating: nil, count: cardButtons.count)
    // (I used lazy only so I could use the count of cardButtons)
    
    var isBoardFull: Bool {
        get {
            // return: cardButtonsMapper is "nil-free"?
            return cardButtonsMapper.filter({$0 != nil}).count == cardButtons.count
        }
    }
    
    // A "helper variable" used to alert when a match is found
    var matchesCounter = 0
    var isAMatchMarked: Bool {
        get {
            return matchesCounter < game.matches.count
        }
    }
    
    /* -------
     Methods
     -------- */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewOpenCardsToMapper()
        updateViewFromMapperAndModel()
        startTimers()
    }
    
    // The sole puprpose of this (overriden) function is to invalidate the timers to prevent reference cycles in memory.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimers()
    }
    
    /* -------------------
     Functions for Buttons
     ---------------------*/
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        cardButtonsMapper = [SetCard?](repeating: nil, count: cardButtons.count)
        game = SetGame()
        
        for index in cardButtons.indices {
            cardButtons[index].isHidden = false
        }
        gameOverLabel.isHidden = true
        matchesCounter = 0
        addNewOpenCardsToMapper()
        updateViewFromMapperAndModel()
        stopTimers()
        startTimers()
    }
    
    @IBAction func dealButtonPressed(_ sender: UIButton) {
        if isAMatchMarked {
            matchesCounter += 1
            game.popThreeCardsFromDeck()
            replaceMatchedCardsOnMapper()
            
            // reset timers
            stopTimers()
            startTimers()
        }
        else if !isBoardFull {
            if game.findMatchInOpenCards() != nil {
                game.score -= 3 // if the user pressed "deal" but there was a match in openCards
            }
            // even if game.findMatchInOpenCards() is nil:
            game.resetCardSelection()
            game.popThreeCardsFromDeck()
            addNewOpenCardsToMapper()
            
            // reset timers
            stopTimers()
            startTimers()
        }
        // in any case :
        // note: timers shouldn't be reset if deal was pressed but board is full
        updateViewFromMapperAndModel()
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let index = cardButtons.firstIndex(of: sender){
            if let chosenCard = cardButtonsMapper[index] {
                if isAMatchMarked { // then this is the 4th card selected after a match
                    // if one of the matched card was clicked again, ignore:
                    if game.selectedCards.contains(chosenCard) {return}
                    else {
                        matchesCounter += 1
                        game.chooseCard(chosenCard: chosenCard)
                        replaceMatchedCardsOnMapper()
                        stopTimers()
                        startTimers()
                    }
                } else {
                    game.chooseCard(chosenCard: chosenCard)
                }
                updateViewFromMapperAndModel()
            } else { // cardButtonsMapper[index] = nil
                print("Pressed on a 'hidden' card.")
            }
        } else {
            print("Encountered an error. The UI included a button which isn't on cardButtons.")
        }
    }
    
    // This function currently doesn't penalize with points reduction (meaning, it rewards the player for a found match).
    @IBAction func cheatButtonPressed(_ sender: UIButton) {
        guard !isAMatchMarked else {return} // if a match is marked, the game is paused, and we can ignore the pressing.
        game.resetCardSelection()
        if let match = game.findMatchInOpenCards() {
            for i in 0..<match.count {
                game.chooseCard(chosenCard: match[i])
            }
        } else {
            print("There isn't a 'set' in the currently open cards")
        }
        updateViewFromMapperAndModel()
    }
    
    /* -------
     Private Methods
     -------- */
    
    // Every time the gameTimer run out of time, the potential score for a match decreases.
    @objc private func updateUserScoreForTime() {
        if game.baseScoreFactor > 0 {
            game.baseScoreFactor -= 10
        }
    }
    
    // Every time the enemyTimer run out of time, the computer marks a match.
    @objc private func makeEnemyTurn() {
        if isAMatchMarked {return} // ignore (if a match is marked, the game is paused).
        
        game.makeEnemyTurn()
        updateViewFromMapperAndModel()
        stopTimers()
    }
    
    // Makes sure cardButtonsMapper is famliar with every open card in the game (Model)
    private func addNewOpenCardsToMapper() {
        for index in game.openCards.indices {
            if !cardButtonsMapper.contains(game.openCards[index]) {
                addGameCardToButtonsMapper(gameCard: game.openCards[index])
            }
        }
    }
    
    /*
     Makes sure that mapper only hold references to current open cards in the game (model)
        [and not cards that were matched and removed]
     */
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

    /*
        Presents game.score, then iterates over all cardButtons (using the cardButtonsMapper) and
        sets their appearance (with the relevant card or as a "covered card")
     */
    private func updateViewFromMapperAndModel() {
        
        userScoreLabel.text = "Score: \(game.score)"
        iphoneScoreLabel.text = "Score: \(game.enemyScore)"
        iphoneStateLabel.text = (game.score >= game.enemyScore) ? enemyLosingTitle : enemyWinningTitle
        
        // Go over all cardButtons (using the careButtonsMapper) and update the info that they present
        for index in cardButtonsMapper.indices {
            let button = cardButtons[index]
            if let card = cardButtonsMapper[index] { // if a card is in that index
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                button.setAttributedTitle(attriubtedStringForCard(card: card), for: UIControl.State.normal)
                button.layer.borderColor = game.selectedCards.contains(card) ? #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1): #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                button.layer.borderWidth = game.selectedCards.contains(card) ? 3.0: 0.0
                
                if let lastMatch = game.matches.last { // take last found match (3 cards)
                    // and if needed, mark the current card as a part of that match
                    button.layer.borderColor = lastMatch.contains(card) ?#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1): #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                } // if lastMatch is nil then there weren't any matches in the game (so no border coloring is needed).
                
            } else { // if nil is in that index (the button should be covered).
                button.setAttributedTitle(nil, for: UIControl.State.normal)
                button.setTitle(nil, for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                button.layer.borderWidth = 0.0
            }
        }
        
        if game.isGameOver {
            for index in cardButtons.indices {
                cardButtons[index].isHidden = true
            }
            gameOverLabel.isHidden = false
            stopTimers()
        }
    }
        
    // Maps a SetCard object to the NSAttributedString representing it (in this implementation).
    private func attriubtedStringForCard(card: SetCard) -> NSAttributedString? {
        // Different filling types for cards get different alpha value for coloring.
        let alpha = (card.filling == SetCard.Filling.typeThree) ? alphaForStripedShapes: alphaForFullShapes
        
        if let color = colorDict[card.color] {
            let attributes: [NSAttributedString.Key: Any] = [
                // different filling types for cards get different .strokeWidth values.
                .strokeWidth: (card.filling == SetCard.Filling.typeTwo) ? strokeWidthForOutlineShapes : strokeWidthForFilledShapes,
                .strokeColor: color,
                .foregroundColor: color.withAlphaComponent(CGFloat(alpha))
                ]
            if let shape = shapesDict[card.shapeType] {
                var string = ""
                for _ in 0..<card.shapesNum.rawValue {
                    string += shape + " "
                }
                return NSAttributedString(string: string, attributes: attributes)
            }
        }
        // next line shouldn't be reached because we assert that all cards have valid "color" property.
        // but it was required by the compiler.
        return NSAttributedString(string: "")
    }
    
    // Inserts the given SetCard object to the first index of cardButtonsMapper that its value is nil.
    private func addGameCardToButtonsMapper(gameCard: SetCard) {
        for index in cardButtonsMapper.indices {
            if cardButtonsMapper[index] == nil {
                cardButtonsMapper[index] = gameCard
                break
            }
        }
    }
    
    // Invalidate timer instances.
    private func stopTimers() {
        gameTimer?.invalidate()
        enemyTimer?.invalidate()
    }
    
    // Start timers and reset the Base for score (which decreases as the timer proceeds).
    private func startTimers() {
        gameTimer = Timer.scheduledTimer(timeInterval: timeForPlayerToFindSet, target: self, selector: #selector(updateUserScoreForTime), userInfo: nil, repeats: true)
        
        let enemyTime = Double.random(in: minWaitingDurationForEnemyTurn..<maxWaitingDurationForEnemyTurn)
        enemyTimer = Timer.scheduledTimer(timeInterval: enemyTime, target: self, selector: #selector(makeEnemyTurn), userInfo: nil, repeats: true)
        game.baseScoreFactor = game.initialBaseScoreFactor
    }
}

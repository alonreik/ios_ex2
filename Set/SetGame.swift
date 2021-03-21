//
//  Set.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import Foundation

struct SetGame
{
    
    /* -------
     Properties
     -------- */
    
    // An arbitrary number utilized to score matches (update score based on matches) based on number of open cards.
    // (The view controller also uses a timer to decreases this value if the player takes a long time to find a match).
    var BaseForScore = 240
    
    var score = 0
    var enemyScore = 0
    private var scoreUpdate: Int {
        // every time a match is found, the scoring update depends on the
        // number of open cards. (more open card = less score)
        get {
            return BaseForScore / openCards.count // (integer division)
        }
    }
    
    private var deck: [SetCard] = []
    private(set) var openCards: [SetCard] = []
    private(set) var selectedCards: [SetCard] = []
    private(set) var matches: [[SetCard]] = []

    
    /* -------
     Initiators
     -------- */
    init() {
        startGame()
    }
    
    
    /* -------
     Methods
     -------- */
    
    // Resets the selectedCards array.
    mutating func resetCardSelection() {
        selectedCards.removeAll()
    }
    
    /*
        If the provided card is already selected: it is diselected or ignored.
        otherwise, the provided card is added to the selected cards, and the necessary updates are preformed.
    */
    mutating func chooseCard(chosenCard: SetCard) {
        // assert that the provided SetCard is currently in the game (in openCards).
        assert(openCards.contains(chosenCard), "Set.chooseCard(currentCard): Provided this function with a reference to a card which isn't in the openCards array.")
        
        // if chosenCard in the selected cards, remove it from selectedCards or ignore (depends of number of selectedCards):
        if selectedCards.contains(chosenCard) {
            if selectedCards.count == 3 {return} // ignore
            else { // selectedCards.count < 3
                selectedCards.remove(object: chosenCard)
            }
        }
        // if the chosen card wasn't already in selectedCards, just add it:
        else if !selectedCards.contains(chosenCard) {
            selectedCards.append(chosenCard)
        }
        
        // if chosen card is the 3rd selected card
        if selectedCards.count == 3 {
            // check for match:
            if chosenCard == getMissingCardForMatch(first: selectedCards[0], second: selectedCards[1]) {
                score += scoreUpdate
                matches.append(selectedCards)
            }
            else {
                // if the user chose a 3rd card which doesn't form a set
                score -= 5 // the user is penalized with 5 points for unsuccessful matches.
            }
        }
        // if the current card was chosen when 3 cards were already selected
        else if selectedCards.count == 4 {
            if let lastMatch = matches.last {
                if selectedCards.contains(other: lastMatch) {
                    openCards.removeAll(where: {value in return selectedCards[0..<3].contains(value)})
                    drawThreeCards()
                } // if the last match is not in selectedCards - do nothing
                
            } // in any case:
            selectedCards.removeFirst(3) // diselect 3 already selected cards

        } // else: selected cards contains 0/1/2 cards, nothing to do there
    }
    
    /*
        If called after a match is found, the function removes the matched cards from openCards.
        Regardless, if the deck has at least 3 cards, the function pops 3 cards from the deck to openCards.
        (and does nothing otherwise).
    */
    mutating func drawThreeCards() {
        if let lastMatch = matches.last {
            if lastMatch == selectedCards {
                openCards.removeAll(where: {value in return selectedCards[0..<3].contains(value)}) // closure
                selectedCards.removeAll()
            }
        }
        if deck.count > 2 {
            openCards.append(contentsOf: deck.prefix(3))
            deck.removeFirst(3)
        } // else - do nothing
    }
    
    
    // Whenever called, this function forms a match (if such exists in openCards) and updates the enemy's score.
    mutating func makeEnemyTurn() {
        if let match = findMatchInOpenCards() {
            // if openCards include 3 cards that form a match.
            selectedCards = match
            matches.append(selectedCards)
            enemyScore += 3
        } // else - do nothing
    }
    
    /*
        This function returns an array of 3 SetCards (subset of openCards) that form a match. Otherwise, it returns nil.
        The algorithm I implemented was found here:
        http://pbg.cs.illinois.edu/papers/set.pdf (The OptimumPairCheck algorithm)
     */
    func findMatchInOpenCards() -> [SetCard]? {
        let (leftHalf, rightHalf) = openCards.split()
        
        for first in 0..<leftHalf.count {
            for second in 0..<leftHalf.count {
                if first == second {continue} // we don't want to send the same card
                
                let missingCardForLeft = getMissingCardForMatch(first: leftHalf[first], second: leftHalf[second])
                let missingCardForRight = getMissingCardForMatch(first: rightHalf[first], second: rightHalf[second])

                if openCards.contains(missingCardForLeft) {
                    return [leftHalf[first], leftHalf[second], missingCardForLeft]
                }
                else if openCards.contains(missingCardForRight) {
                    return [rightHalf[first], rightHalf[second], missingCardForRight]
                } // else : do nothing
            }
        }
        
        if rightHalf.count > leftHalf.count {
            for i in 0..<rightHalf.count {
                if i == rightHalf.count - 1 {continue} //
                let missingCardForRight = getMissingCardForMatch(first: rightHalf[i], second: rightHalf[rightHalf.count - 1])
                if openCards.contains(missingCardForRight) {
                    return [rightHalf[i], rightHalf[rightHalf.count - 1], missingCardForRight]
                }
            }
        }
        return nil
    }
         
    
    /* ------------
     Private Methods
     ------------- */
    
    // Returns an initial shuffled Deck of 81 unique SetCard instances.
    private func getInitialDeck() -> [SetCard] {
        
        var resultDeck = [SetCard]()
        for shape in SetCard.legalValues {
            for numShapes in SetCard.legalValues {
                for filling in SetCard.legalValues {
                    for color in SetCard.legalValues {
                        resultDeck.append(SetCard(shapeType: shape, shapesNum: numShapes, filling: filling, color: color))
                    }
                }
            }
        }
        return resultDeck.shuffled()
    }
    
    // Resets the SetGame's instance properties (sets scores = 0, resets deck and openCards, then open 12 cards).
    private mutating func startGame() {
        
        // reset scores
        enemyScore = 0
        score = 0
        BaseForScore = 240
        
        // initiate an 81 SetCards deck
        deck = getInitialDeck()
        
        // reset openCards and selectdCards arrays, and open first 12 cards from the deck
        openCards = []
        selectedCards = []
        
        openCards.append(contentsOf: deck.prefix(12))
        deck.removeFirst(12)
    }
    
    // Given any two setCards , returns the one and only other card that forms a set with them.
    private func getMissingCardForMatch(first: SetCard, second: SetCard) -> SetCard {
                
        let shapeType = getMissingAttrbuteForMatch(firstAttribute: first.shapeType, secondAttribute: second.shapeType)
        let shapesNum = getMissingAttrbuteForMatch(firstAttribute: first.shapesNum, secondAttribute: second.shapesNum)
        let filling = getMissingAttrbuteForMatch(firstAttribute: first.filling, secondAttribute: second.filling)
        let color = getMissingAttrbuteForMatch(firstAttribute: first.color, secondAttribute: second.color)
        
        return SetCard(shapeType: shapeType, shapesNum: shapesNum, filling: filling, color: color)
    }
    
    // Given any two setCards' properties, returns the one and only other property that may form a set with them.
    private func getMissingAttrbuteForMatch(firstAttribute: Int, secondAttribute: Int) -> Int {
        var legalValues = SetCard.legalValues
        legalValues.remove(object: firstAttribute)
        legalValues.remove(object: secondAttribute)
        
        // if the given attributes are equal - return one of them. otherwise, return the 3rd remaining property.
        return firstAttribute == secondAttribute ? firstAttribute : legalValues[0]
    }
}

/* Extensions :
 (One of the exercise tasks was to implement and use an extensions)
 */

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given object:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

extension Array {
    
    // Splits an array in half, and returns both halves in a tuple: (leftHalf, rightHalf).
    func split() -> (left: [Element], right: [Element]) {
        let half = self.count / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< self.count]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
}

extension Array where Element: Equatable {
    
    // Returns true iff the given array is a subset of "self".
    mutating func contains(other: Array) -> Bool {
        for item in other {
            if !self.contains(item) {
                return false
            }
        }
        return true
    }
}

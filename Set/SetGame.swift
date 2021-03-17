//
//  Set.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import Foundation

struct SetGame
{
    // Static Methods:
    
    /*
        Returns true iff (if and only if) the 3 provided setCards satisfy all conditions for a "set"
        (the method uses the funcionality of mathematical-sets to check if the cards are exactly the same or entirely different in each parameter).
     */
    static func areCardsMatching(c1: SetCard, c2: SetCard, c3: SetCard) -> Bool {

        let shapesTypes: Set<Int> = [c1.shapeType, c2.shapeType, c3.shapeType]
        let shapesNumber: Set<Int> = [c1.shapesNum, c2.shapesNum, c3.shapesNum]
        let shapesFill: Set<Int> = [c1.filling, c2.filling, c3.filling]
        let shapesColor: Set<Int> = [c1.color, c2.color, c3.color]
        
        return shapesTypes.count != 2 && shapesNumber.count != 2 && shapesFill.count != 2 && shapesColor.count != 2
    }
        
    
    // Properties
    
    var deck: [SetCard] = []// todo - should be optional?
    
    var openCards: [SetCard] = [] // todo should be optional?
    
    var score = 0
    
    var selectedCards: [SetCard] = []
    
    var matches: [[SetCard]] = []// every item in this array is of the form [SetCard, SetCard, SetCard]
    
    // Initiators
    init () {
        startGame()
    }    
    
    // Methods
    
    /*
    
    */
    mutating func chooseCard(chosenCard: SetCard) {
        // assert that the provided SetCard is currently in the game.
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
        
        //
        if selectedCards.count == 3 {
            if SetGame.areCardsMatching(c1: selectedCards[0], c2: selectedCards[1], c3: selectedCards[2]) {
                score += 1 // TODO - update score correctly
                matches.append(selectedCards)
            }
        }
        else if selectedCards.count == 4 {
            if SetGame.areCardsMatching(c1: selectedCards[0], c2: selectedCards[1], c3: selectedCards[2]) {
                openCards.removeAll(where: {value in return selectedCards[0..<3].contains(value)}) // closure
                drawThreeCards()
            }
            selectedCards.removeFirst(3)

        } // else selected cards contains 0/1/2 cards, nothing to do there
    }
    
    // Removes 3 cards from the deck and places them in the array of openCards.
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
         
    
    // Private Methods
    
    
    // Returns an initial shuffled Deck of 81 SetCard unique instances.
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
    
    // Resets the SetGame's instance properties.
    private mutating func startGame() {
        
        // reset score
        score = 0
        
        // initiate an 81 SetCards deck
        deck = getInitialDeck()
        
        // reset openCards array, and open first 12 cards from the deck
        openCards = []
        openCards.append(contentsOf: deck.prefix(12))
        deck.removeFirst(12)
    }
}

// One of the exercise tasks was to implement and use an extension:
extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

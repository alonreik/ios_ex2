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
    static func areMatching(c1: SetCard, c2: SetCard, c3: SetCard) -> Bool {

        let shapesTypes: Set<Int> = [c1.shapeType, c2.shapeType, c3.shapeType]
        let shapesNumber: Set<Int> = [c1.shapesNum, c2.shapesNum, c3.shapesNum]
        let shapesFill: Set<Int> = [c1.filling, c2.filling, c3.filling]
        let shapesColor: Set<Int> = [c1.color, c2.color, c3.color]
        
        return shapesTypes.count != 2 && shapesNumber.count != 2 && shapesFill.count != 2 && shapesColor.count != 2
    }
        
    
    // Properties
    
    var deck: [SetCard] = [] // todo - should be optional?
    
    var openCards: [SetCard] = [] // todo should be optional?
    
    var score = 0
    
    var selectedCards: [SetCard] = []
    
    var matches: [[SetCard]] = [] // every item in this array is of the form [SetCard, SetCard, SetCard]
    
    // Initiators
    init () {
        startGame()
    }    
    
    // Methods
    
    /*
    
    */
    mutating func chooseCard(at index: Int) {
        assert(openCards.indices.contains(index), "Set.chooseCard(at: \(index)): chosen index is not in the open cards")
        
        let currentCard = openCards[index]
        if selectedCards.contains(currentCard){// if a selected card was picked again, ignore.
            return}
        
        if selectedCards.count == 3 { // if there were already 3 selected cards
            if matches.contains(selectedCards) { // if the 3 selected cards are a match
                openCards = openCards.filter({!selectedCards.contains($0)}) // remove selected cards from open cards
            }
            selectedCards.removeAll() // in any case, reset selected cards
        }
        selectedCards.append(currentCard)
        
        if selectedCards.count == 3 { // if the current card is the third selected card
            if SetGame.areMatching(c1: selectedCards[0], c2: selectedCards[1], c3: selectedCards[2]) {
                score += 1 // TODO - update score correctly
                matches.append(selectedCards)
            }
        }
    }
    
    // Removes 3 cards from the deck and places them in the array of openCards.
    mutating func drawThreeCards() {
        
        assert(deck.count > 2, "SetGame.drawThreeCards(): Tried to draw cards from a deck with less than 3 cards. ")
        
        openCards.append(contentsOf: deck.prefix(3))
        deck.removeFirst(3)
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

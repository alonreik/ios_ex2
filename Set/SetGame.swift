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
    static func isMatch(c1: SetCard, c2: SetCard, c3: SetCard) -> Bool {

        let shapesTypes: Set<Int> = [c1.shapeType, c2.shapeType, c3.shapeType]
        let shapesNumber: Set<Int> = [c1.shapesNum, c2.shapesNum, c3.shapesNum]
        let shapesFill: Set<Int> = [c1.filling, c2.filling, c3.filling]
        let shapesColor: Set<Int> = [c1.color, c2.color, c3.color]
        
        return shapesTypes.count != 2 && shapesNumber.count != 2 && shapesFill.count != 2 && shapesColor.count != 2

    }
        
    
    // Properties
    
    private var deck: [SetCard] = [] // todo - should be optional?
    
    private var openCards: [SetCard] = [] // todo should be optional?
    
    private var score = 0
    
    private var selectedCards: [SetCard]? {
        get {
            // The line below is equivalent to:
            // return openCards.filter({(c1: SetCard) -> Bool in return c1.isSelected})
            return openCards.filter({$0.isSelected})
        }
    }
    
    // Initiators
    init () {
        startGame()
    }
    
    
    // Methods
    
    /*
        Returns an initial shuffled Deck of 81 SetCard unique instances.
     */
    func getInitialDeck() -> [SetCard] {
        var resultDeck: [SetCard] = []
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
         
    
    
    // Private Methods
    
    private mutating func startGame() {
        
        // reset score
        score = 0
        
        // initiate an 81 SetCards deck
        deck = getInitialDeck()
        
        // open first 12 cards from the deck
        openCards.append(contentsOf: deck.prefix(12))
        deck.removeFirst(12)
        
    }
    
}


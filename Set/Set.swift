//
//  Set.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import Foundation

struct Set
{
    // Static Methods
        // todo - method of is a match? (gets 3 cards)
    
    
    
    // Properties
    
    private var deck: [SetCard] = [] // todo - should be optional?
    
    private var openCards: [SetCard] = [] // todo should be optional?
    
    private var score = 0
    private var selectedCards: [SetCard]? {
        get {
            return openCards.filter({$0.isSelected})
        }
    }
    
    
    
    // Initiators
    init () {
        self.deck = getInitialDeck()
    }
    
    
    // Methods
    
    /*
     
     */
    func getInitialDeck() -> [SetCard] {
        var resultDeck: [SetCard] = []
        for shape in 1...3 {
            for numShapes in 1...3 {
                for shapeFilling in 1...3 {
                    resultDeck.append(SetCard(shapeType: shape, shapesNum: numShapes, shapeFilling: shapeFilling))
                }
            }
        }
        return resultDeck
    }
}

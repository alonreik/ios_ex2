//
//  Card.swift
//  Concentration
//
//  Created by Alon Reik on 09/03/2021.
//

import Foundation

struct Card
{
    var wasSeen = false
    var isFaceUp = false
    var isMatched = false
    var identifier: Int
    
    static var identifierFactory = 0
    
    static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return Card.identifierFactory
    }
    
    init() {
        self.identifier = Card.getUniqueIdentifier()
    }
    
    // Resets a card object to its initial values.
    mutating func resetCard() {
        isFaceUp = false
        isMatched = false
        wasSeen = false
    }
    
}

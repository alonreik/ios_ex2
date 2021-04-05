//
//  Concentration.swift
//  Concentration
//
//  Created by Alon Reik on 09/03/2021.
//

import Foundation

class Concentration
{
    var score = 0
    var flipCount = 0
    var cards = [Card]()
    var indexOfOneAndOnlyFaceUpCard: Int?
    
    func chooseCard(at index: Int) {
        if !cards[index].isMatched {
            
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // if another card is already facing up:
                if cards[matchIndex].identifier == cards[index].identifier { // if cards match:
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    score += 2
                } else { // if cards don't match:
                    var penalty = 0
                    if cards[index].wasSeen, cards[matchIndex].wasSeen {
                        penalty += 2
                    }
                    else if cards[matchIndex].wasSeen || cards[index].wasSeen {
                        penalty += 1
                    }
                    score -= penalty
                } // things to do every time a second card in a turn is picked:
                cards[index].wasSeen = true
                cards[matchIndex].wasSeen = true
                cards[index].isFaceUp = true
                indexOfOneAndOnlyFaceUpCard = nil
            
            } else {
                // either no cards or 2 cards are face up
                for flipDownIndex in cards.indices {
                    cards[flipDownIndex].isFaceUp = false
                }
                cards[index].isFaceUp = true
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    
    init(numberOfPairsOfCards: Int) {
        for _ in 0..<numberOfPairsOfCards {
            let card = Card()
            cards.append(card)
            cards.append(card) // The matching card 
        }
        cards.shuffle()
    }
    
    // Resets all Card objects and the score counting.
    func resetGame() {
        flipCount = 0
        score = 0
        for index in cards.indices {
            cards[index].resetCard()
        }
        cards.shuffle()
    }
}

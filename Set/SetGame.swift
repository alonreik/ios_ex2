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
     Constants
     -------- */

    let initialNumberOfOpenCards = 12
    let falseMatchPenalty = 5
    let unRequiredDrawPenalty = 3

    /* -------
     Properties
     -------- */
    
    var isGameOver: Bool {
        get {
            return deck.isEmpty && findMatchInOpenCards() == nil
        }
    }
    
    private(set) var openCards: [SetCard] = []
    private(set) var deck: [SetCard] = []
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
    
    // Shuffles the cards' order openCards.
    mutating func shuffleOpenCards() {
        openCards.shuffle()
    }
    
    /*
        If the provided card is already selected: it is diselected or ignored.
        otherwise, the provided card is added to the selected cards, and the necessary updates are preformed.
    */
    mutating func chooseCard(chosenCard: SetCard) {
        // assert that the provided SetCard is currently in the game (in openCards).
        assert(openCards.contains(chosenCard), "Set.chooseCard(currentCard): Provided this function with a reference to a card which isn't in the openCards array.")
        
        // if chosenCard is in selectedCards, remove it or ignore (depends of number of selectedCards):
        if selectedCards.contains(chosenCard) {
            if selectedCards.count == 3 {return} // ignore
            else { // selectedCards.count < 3
                selectedCards.remove(object: chosenCard)
            }
        } else { // if the chosen card wasn't already in selectedCards, just add it:
            selectedCards.append(chosenCard)
        }
        
        // if chosen card is the 3rd selected card
        if selectedCards.count == 3 {
            // check for match:
            if chosenCard == getMissingCardForMatch(first: selectedCards[0], second: selectedCards[1]) {
                matches.append(selectedCards)
            }
        }
        
        // if the current card was chosen when 3 cards were already selected
        else if selectedCards.count == 4 {
            if let lastMatch = matches.last {
                if selectedCards.contains(other: lastMatch) {
                    replaceMatchWithCardsFromDeck()
                }
            }
            selectedCards.removeFirst(3)
        }
    }
    
    // When a 4th card is selected after a match is found, new cards from the deck
    // will replace the 3 matched cards (the new cards will get the position of the
    // old cards in openCards)
    mutating func replaceMatchWithCardsFromDeck() {
        // replace matched selected cards with new cards from deck
        for card in selectedCards[0..<3] {
            if let index = openCards.firstIndex(of: card) {
                if deck.count > 0 {
                    openCards[index] = deck.removeFirst()
                } else {
                    openCards.remove(object: card)
                }
            }
        }
    }
    
    /*
        If called after a match is found, the function removes the matched cards from openCards.
        Regardless, if the deck has at least 3 cards, the function pops 3 cards from the deck to openCards.
        (and does nothing otherwise).
    */
    mutating func popThreeCardsFromDeck() {
        if deck.count > 2 {
            openCards.append(contentsOf: deck.prefix(3))
            deck.removeFirst(3)
        } // else - do nothing
    }
    
    /*
        This function returns an array of 3 SetCards (subset of openCards) that form a match.
        Otherwise (if no match is found), it returns nil.
        The algorithm I implemented was found here:
        http://pbg.cs.illinois.edu/papers/set.pdf (The OptimumPairCheck algorithm)
     */
    func findMatchInOpenCards() -> [SetCard]? {
        let (leftHalf, rightHalf) = openCards.splitToTwo()
        
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
                if i == rightHalf.count - 1 {continue}
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
        
        for shape in SetCard.Shape.allCases {
            for numShapes in SetCard.NumberOfShapes.allCases {
                for filling in SetCard.Filling.allCases {
                    for color in SetCard.Color.allCases {
                        resultDeck.append(SetCard(shapeType: shape, shapesNum: numShapes, filling: filling, color: color))
                    }
                }
            }
        }
        return resultDeck.shuffled()
    }
    
    // Resets the SetGame's instance properties (resets deck and openCards, then open 12 cards).
    private mutating func startGame() {
        
        // initiate an 81 SetCards deck
        deck = getInitialDeck()
        
        // reset openCards and selectdCards arrays, and open first 12 cards from the deck
        openCards = []
        selectedCards = []
        
        openCards.append(contentsOf: deck.prefix(initialNumberOfOpenCards))
        deck.removeFirst(initialNumberOfOpenCards)
    }
    
    // Given any two setCards , returns the one and only other card that forms a set with them.
    private func getMissingCardForMatch(first: SetCard, second: SetCard) -> SetCard {
                
        var allColors = SetCard.Color.allCases
        allColors.remove(object: first.color)
        allColors.remove(object: second.color)
        // if the given cards' color are equal - return one of them. otherwise, return the 3rd remaining color.
        let color = first.color == second.color ? first.color : allColors[0]
        
        var allShapes = SetCard.Shape.allCases
        allShapes.remove(object: first.shapeType)
        allShapes.remove(object: second.shapeType)
        // if the given cards' shapes are equal - return one of them. otherwise, return the 3rd remaining shape.
        let shapeType = first.shapeType == second.shapeType ? first.shapeType : allShapes[0]

        var allFilling = SetCard.Filling.allCases
        allFilling.remove(object: first.filling)
        allFilling.remove(object: second.filling)
        // if the given cards' filling are equal - return one of them. otherwise, return the 3rd remaining filling.
        let filling = first.filling == second.filling ? first.filling : allFilling[0]
        
        var allPossibleNumbersOfShapes = SetCard.NumberOfShapes.allCases
        allPossibleNumbersOfShapes.remove(object: first.shapesNum)
        allPossibleNumbersOfShapes.remove(object: second.shapesNum)
        // if the given cards show same number - return one that number. otherwise, return the 3rd remaining number.
        let shapesNum = first.shapesNum == second.shapesNum ? first.shapesNum : allPossibleNumbersOfShapes[0]
        
        return SetCard(shapeType: shapeType, shapesNum: shapesNum, filling: filling, color: color)
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
    func splitToTwo() -> (left: [Element], right: [Element]) {
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

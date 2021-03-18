//
//  Set.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import Foundation

struct SetGame
{
    
    /* ------------
     Static Methods
     -------------- */
        
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
        
    /* -------
     Properties
     -------- */
    
    // An arbitrary number utilized to score matches (update score based on matches) based on number of open cards.
    // (The view controller also uses a timer to decreases this value if the player takes a long time to find a match).
    var BaseForScore = 240
    
    var score = 0
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
    // The var below is a subset of openCards (it may include 3 cards from openCards that form a match)

    
    /* -------
     Initiators
     -------- */
    init() {
        startGame()
    }
    
    
    /* -------
     Methods
     -------- */
    
    // as advertized, resets the selectedCards array. 
    mutating func resetCardSelection() {
        selectedCards = []
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
            if SetGame.areCardsMatching(c1: selectedCards[0], c2: selectedCards[1], c3: selectedCards[2]) {
                score += scoreUpdate
                matches.append(selectedCards)
            } else {
                score -= 5
            }
        }
        // if the current card was chosen when 3 cards were already selected
        else if selectedCards.count == 4 {
            if SetGame.areCardsMatching(c1: selectedCards[0], c2: selectedCards[1], c3: selectedCards[2]) {
                // remove 3 already selected cards from the game (from open cards):
                openCards.removeAll(where: {value in return selectedCards[0..<3].contains(value)})
                
                drawThreeCards()
            }
            selectedCards.removeFirst(3) // diselect 3 already selected cards

        } // else selected cards contains 0/1/2 cards, nothing to do there
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
    
    /*
        The algorithm I implemented was found here:
        http://pbg.cs.illinois.edu/papers/set.pdf
        (The OptimumPairCheck algorithm)
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
    
    // Resets the SetGame's instance properties (sets score = 0, resets deck, then open 12 cards).
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
    
    // Given any two setCards , returns the one and only other card that forms a set with them.
    private func getMissingCardForMatch(first: SetCard, second: SetCard) -> SetCard {
        
        // calculate the shape of the missing card
        var legalValues = SetCard.legalValues
        legalValues.remove(object: first.shapeType)
        legalValues.remove(object: second.shapeType)
        let shapeType = (first.shapeType == second.shapeType) ? first.shapeType : legalValues[0]
        
        // calculate the number of shapes of the missing card
        legalValues = SetCard.legalValues
        legalValues.remove(object: first.shapesNum)
        legalValues.remove(object: second.shapesNum)
        let shapesNum = (first.shapesNum == second.shapesNum) ? first.shapesNum : legalValues[0]
        
        // calculate the filling type of the missing card
        legalValues = SetCard.legalValues
        legalValues.remove(object: first.filling)
        legalValues.remove(object: second.filling)
        let filling = (first.filling == second.filling) ? first.filling : legalValues[0]
        
        // calculate the color of the missing card
        legalValues = SetCard.legalValues
        legalValues.remove(object: first.color)
        legalValues.remove(object: second.color)
        let color = (first.color == second.color) ? first.color : legalValues[0]
        
        return SetCard(shapeType: shapeType, shapesNum: shapesNum, filling: filling, color: color)
    }
}

/* Extensions :
 (One of the exercise tasks was to implement and use an extensions)
 */

// Remove first collection element that is equal to the given object:
extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

// Splits an array in half, and returns both halves in a tuple: (leftHalf, rightHalf).
extension Array {
    func split() -> (left: [Element], right: [Element]) {
        let half = self.count / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< self.count]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
}

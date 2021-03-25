//
//  SetCard.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import Foundation

// it is a class because i want it to be a reference type
class SetCard: Equatable, Hashable
{
    
    /* ------------
     Static Methods
     ------------- */

    /*
        Returns true iff both SetCard instances has equal values in every property. 
     */
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.shapeType == rhs.shapeType && lhs.shapesNum == rhs.shapesNum && lhs.filling == rhs.filling && lhs.color == rhs.color
    }
    
    /* -------
     Properties
     -------- */
    
    let shapeType: Shape
    let shapesNum: NumberOfShapes
    let filling: Filling
    let color: Color
    
    /* -------
     Initiators
     -------- */
    
    init (shapeType: Shape, shapesNum: NumberOfShapes, filling: Filling, color: Color) {
        self.shapeType = shapeType
        self.shapesNum = shapesNum
        self.filling = filling
        self.color = color
    }
    
    enum Shape: CaseIterable {
        case typeOne
        case typeTwo
        case typeThree
    }

    enum Filling: CaseIterable {
        case typeOne
        case typeTwo
        case typeThree
    }
    
    enum Color: CaseIterable {
        case typeOne
        case typeTwo
        case typeThree
    }
    
    enum NumberOfShapes: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shapeType)
        hasher.combine(shapesNum)
        hasher.combine(filling)
        hasher.combine(color)
    }
}

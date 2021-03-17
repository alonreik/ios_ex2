//
//  SetCard.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import Foundation

// it is a class because i want it to be a reference type
class SetCard: Equatable
{
    
    // Static Methods

    /*
        Returns true iff both SetCard instances has equal values in every property. 
     */
    static func ==(lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.shapeType == rhs.shapeType && lhs.shapesNum == rhs.shapesNum && lhs.filling == rhs.filling && lhs.color == rhs.color
    }
    
    // Properties
    
    let shapeType: Int
    let shapesNum: Int
    let filling: Int
    let color: Int
        
    // TODO 
    static let legalValues = 1...3
    
    // Initiators
    init (shapeType: Int, shapesNum: Int, filling: Int, color: Int) {
        
        // assert that all given values are valid.
        assert(SetCard.legalValues.contains(shapeType) && SetCard.legalValues.contains(shapesNum) && SetCard.legalValues.contains(filling) && SetCard.legalValues.contains(color), "SetCard.init(\(shapeType), \(shapesNum), \(filling)): One of the provided values is not in the range 1..3")
        
        self.shapeType = shapeType
        self.shapesNum = shapesNum
        self.filling = filling
        self.color = color
    }
    
    
    // Methods
    
    
    
}

//
//  SetCard.swift
//  Set
//
//  Created by Alon Reik on 15/03/2021.
//

import Foundation

struct SetCard
{
    // Properties
    let shapeType: Int
    let shapesNum: Int
    let filling: Int
    let color: Int
    
    private var matched = false
    var isSelected = false
    
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

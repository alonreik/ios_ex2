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
    private let shapeType: Int
    private let shapesNum: Int
    private let shapeFilling: Int
    
    private var matched = false
    
    var isSelected = false
    
    // Initiators
    
    init (shapeType: Int, shapesNum: Int, shapeFilling: Int) {
        let legalValues = 1...3
        
        assert(legalValues.contains(shapeType) && legalValues.contains(shapesNum) && legalValues.contains(shapeFilling), "SetCard.init(\(shapeType), \(shapesNum), \(shapeFilling)): One of the provided values is not in the range 1..3")
        
        self.shapeType = shapeType
        self.shapesNum = shapesNum
        self.shapeFilling = shapeFilling
    }
    
    
    // Methods
    
}

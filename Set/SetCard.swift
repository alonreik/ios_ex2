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
        self.shapeType = shapeType
        self.shapesNum = shapesNum
        self.shapeFilling = shapeFilling
    }
    
    
    // Methods
    
}

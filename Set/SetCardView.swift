//
//  SetCardView.swift
//  Set
//
//  Created by Alon Reik on 24/03/2021.
//

import UIKit

class SetCardView: UIView
{
    /* ---- */
    
    
    // 1, 2, 3
    var numberOfShapes = 1 {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    } // is needs layout necessary?
    
    // "▲", "●", "■"
    var shape = "▲" {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    var color: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    var filling = "" {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    
    private func attriubtedStringForCard() -> NSAttributedString? {
        // Different filling types for cards get different alpha value for coloring.
        let alpha = (filling == "striped") ? CGFloat(0.15): CGFloat(1.0)
        let attributes: [NSAttributedString.Key: Any] = [
            // different filling types for cards get different .strokeWidth values.
            .strokeWidth: (filling == "outline") ? 5.0 : -5.0,
            .strokeColor: color,
            .foregroundColor: color.withAlphaComponent(alpha)
            ]
        var string = ""
        for _ in 0..<numberOfShapes {
            string += shape + " "
        }
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    
    /* ---- */
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

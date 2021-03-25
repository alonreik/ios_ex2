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
    
    
    // possible number of shapes in a card:
    // 1, 2, 3
    var numberOfShapes = 3 {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    } // is needs layout necessary?
    
    // possible shapes:
    // "▲", "●", "■"
    var shape = "▲" {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }

    // possible colors:
    // #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    // #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    // #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    var color: UIColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1) {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    // possible fillings:
    // striped, outline, full
    var filling = "full" {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    //
    private func attriubtedStringForCard(fontSize: CGFloat) -> NSAttributedString? {
//        private func attriubtedStringForCard(fontSize: CGFloat) -> NSAttributedString? {

        // create a preffered font with the given size.
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)

        // The line below makes the font size adjust to people changing display settings on Iphone.
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)

        // This way we set a centered text (paragraph style)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        
        // Different filling types for cards get different alpha value for coloring.
        let alpha = (filling == "striped") ? CGFloat(0.15): CGFloat(1.0)
        let attributes: [NSAttributedString.Key: Any] = [
            // different filling types for cards get different .strokeWidth values.
            .strokeWidth: (filling == "outline") ? 5.0 : -5.0,
            .strokeColor: color,
            .foregroundColor: color.withAlphaComponent(alpha),
            .paragraphStyle: paragraphStyle,
            .font: font
            ]
        var string = ""
        for _ in 0..<numberOfShapes {
            string += shape + " "
        }
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    
    /* ---- */
    
    /* */
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // todo - figure out font size
        guard let attributedString = attriubtedStringForCard(fontSize: CGFloat(10.0)) else {
            print("failed the let")
            return
        }

        // todo - figure out inset by
        let cardRect = bounds.insetBy(dx: 0, dy: 20)
        attributedString.draw(in: cardRect)
    }
}

//
//  SetCardView.swift
//  Set
//
//  Created by Alon Reik on 24/03/2021.
//

import UIKit

class SetCardView: UIView
{
    
    /* ------
     Constants
     -------*/
    
    let borderWidthForAllCards = CGFloat(2.0)
    
    // Shapes' "strokeWidth" should be positive only for outlined shapes.
    let strokeWidthValueForOutline = CGFloat(5.0)
    let strokeWidthValueNotForOutline = CGFloat(-5.0)

    // Cards with "striped" filling get different alpha values (for coloring) than other cards.
    let alphaForStripedShapes: CGFloat = 0.15
    let alphaForFullShapes: CGFloat = 1.0
    
    
    
    /* ------
     Enums
     -------*/
    
    enum Shape {
        case triangle
        case circle
        case square
    }
    enum Filling: String {
        case full
        case outline
        case striped
    }
    enum Color {
        case pink
        case purple
        case green
    }
    enum Quantity: Int {
        case single = 1
        case double = 2
        case triple = 3
    }
    
    /* --------
     Propeties
     --------- */
    
    var numberOfShapes: Quantity = .double {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    } // is needs layout necessary?
    
    var shape: Shape = .circle {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }

    var color: Color = .pink {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    var filling: Filling = .full {
        didSet {setNeedsDisplay(); setNeedsLayout()}
    }
    
    /* --------
     Initializers
     --------- */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialViewSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialViewSetup()
    }
    
    private func initialViewSetup() {
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderWidth = borderWidthForAllCards
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    /* -------
     Methods
     -------- */
    
    // Draws an attributed string representing a setCard in the middle of self (a SetCardView).
    override func draw(_ rect: CGRect) {
        let attributedString = attriubtedStringForCard()
            
        // define a rectangle to "draw" the attributedString inside of
        let cardRect = CGRect(x: bounds.midX - (attributedString.size().width / 2),
                              y: bounds.midY - (attributedString.size().height / 2),
                              width: attributedString.size().width,
                              height: attributedString.size().height)
        
        // preform the drawing
        attributedString.draw(in: cardRect)
    }
    
    
    /* -------------
     Private Methods
     ------------- */
    
    // Creates and returns an NSAttributedString representing self (a setCardView instance).
    private func attriubtedStringForCard() -> NSAttributedString {
        
        // make adjustments so the attributed string will be automatically scaled and centered when needed:
    
        // create a preffered font with the given size.
        var font = UIFont.preferredFont(forTextStyle: .body)
        
        // The line below makes the font size adjust to people changing display settings on Iphone.
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)

        // This way we set a centered text (paragraph style)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        
        // define attributes for the attributed string:
        
        let cardColor = getColorLiteral()
        let shapeString = getShapeString()
        
        // Different filling types for cards get different alpha value for coloring.
        let alphaForColoring: CGFloat
        switch filling {
        case .striped:
            alphaForColoring = alphaForStripedShapes
        default:
            alphaForColoring = alphaForFullShapes
        }
        
        // Different filling types for cards get different strokeWidth values.
        let strokeWidthValue: CGFloat
        switch filling {
        case .outline:
            strokeWidthValue = strokeWidthValueForOutline
        default:
            strokeWidthValue = strokeWidthValueNotForOutline
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .strokeWidth: strokeWidthValue,
            .strokeColor: cardColor,
            .foregroundColor: cardColor.withAlphaComponent(alphaForColoring),
            .paragraphStyle: paragraphStyle,
            .font: font
            ]
        
        // initialize empty string and "build it"
        var string = String()
        for _ in 0..<numberOfShapes.rawValue {
            string += shapeString
        }
        
        // return the builded string with the appropiate attributes
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    
    // Returns the string representing self.shape.
    private func getShapeString() -> String {
        switch shape {
        case .triangle: return "▲"
        case .circle: return "●"
        case .square: return "■"
        }
    }
    
    // Returns the color literal representing self.color.
    private func getColorLiteral() -> UIColor {
        switch color {
        case .green: return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .purple: return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        case .pink: return #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
    }
}

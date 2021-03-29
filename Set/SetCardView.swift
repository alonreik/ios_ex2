//
//  SetCardView.swift
//  Set
//
//  Created by Alon Reik on 24/03/2021.
//

import UIKit

class SetCardView: UIView
{
    /* -- enums  -- */
    
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
    
    private func getShapeString() -> String {
        switch shape {
        case .triangle: return "▲"
        case .circle: return "●"
        case .square: return "■"
        }
    }
    
    private func getColorLiteral() -> UIColor {
        switch color {
        case .green: return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .purple: return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        case .pink: return #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
    }
    
    
    /* -- Initializers -- */
    
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
        layer.borderWidth = 2.0
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    
    /* -- Propeties -- */
    
    var isSelected = false
    
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
    
    //
    private func attriubtedStringForCard() -> NSAttributedString? {
        
        let cardColor = getColorLiteral()
        let shapeString = getShapeString()
        
        // create a preffered font with the given size.
        var font = UIFont.preferredFont(forTextStyle: .body)
        
        // The line below makes the font size adjust to people changing display settings on Iphone.
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)

        // This way we set a centered text (paragraph style)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // Different filling types for cards get different alpha value for coloring.
        let alpha = (filling.rawValue == "striped") ? CGFloat(0.15): CGFloat(1.0)
        let attributes: [NSAttributedString.Key: Any] = [
            // different filling types for cards get different .strokeWidth values.
            .strokeWidth: (filling.rawValue == "outline") ? 5.0 : -5.0,
            .strokeColor: cardColor,
            .foregroundColor: cardColor.withAlphaComponent(alpha),
            .paragraphStyle: paragraphStyle,
            .font: font
            ]
        
        var string = ""
        for _ in 0..<numberOfShapes.rawValue {
            string += shapeString
        }
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    /* ---- */
    
    /* */
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        guard let attributedString = attriubtedStringForCard() else {
            return
        }

        //
        let cardRect = CGRect(x: bounds.midX - (attributedString.size().width / 2),
                              y: bounds.midY - (attributedString.size().height / 2),
                              width: attributedString.size().width,
                              height: attributedString.size().height)
        
        //
        attributedString.draw(in: cardRect)
        
    }
    
}

// todo - maybe delete
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

//
//  UITextField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/29/25.
//

import UIKit

extension UITextField {
    private static var isValidKey: UInt8 = 0
    
    var isValidate: Bool {
        get {
            return objc_getAssociatedObject(self, &UITextField.isValidKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UITextField.isValidKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var isSuccess: Bool {
            get {
                return objc_getAssociatedObject(self, &UITextField.isValidKey) as? Bool ?? false
            }
            set {
                objc_setAssociatedObject(self, &UITextField.isValidKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            }
        }
}

extension UIBezierPath {
    func addTopRightCorner(from point1: CGPoint, to point2: CGPoint, with radius: CGFloat) {
        let startAngle = -(CGFloat.pi / 2)
        let endAngle = CGFloat.zero
        let center = CGPoint(x: point1.x, y: point2.y)
        addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    func addBottomRightCorner(from point1: CGPoint, to point2: CGPoint, with radius: CGFloat) {
        let startAngle = CGFloat.zero
        let endAngle = -((CGFloat.pi * 3) / 2)
        let center = CGPoint(x: point2.x, y: point1.y)
        addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    func addBottomLeftCorner(from point1: CGPoint, to point2: CGPoint, with radius: CGFloat) {
        let startAngle = -((CGFloat.pi * 3) / 2)
        let endAngle = -CGFloat.pi
        let center = CGPoint(x: point1.x, y: point2.y)
        addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    func addTopLeftCorner(from point1: CGPoint, to point2: CGPoint, with radius: CGFloat) {
        let startAngle = -CGFloat.pi
        let endAngle = -(CGFloat.pi / 2)
        let center = CGPoint(x: point1.x + radius, y: point2.y + radius)
        addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
}

public struct ColorModel {
    /// Text color.
    public var textColor: UIColor
    /// Floating label color.
    public var floatingLabelColor: UIColor
    /// Normal label color.
    public var normalLabelColor: UIColor
    /// Outline line color.
    public var outlineColor: UIColor
    
    public init(with state: MaterialTextFeild.XState) {
        var textColor = UIColor.black
        var floatingLabelColor = UIColor.black
        var normalLabelColor = UIColor.darkGray
        var outlineColor = UIColor.black
        
        if #available(iOS 13.0, *) {
            textColor = .label
            floatingLabelColor = .label
            normalLabelColor = .label
            outlineColor = .label
        }
        
        let disabledAlpha: CGFloat = 0.6
        
        if state == .disabled {
            textColor = textColor.withAlphaComponent(disabledAlpha)
            floatingLabelColor = floatingLabelColor.withAlphaComponent(disabledAlpha)
            normalLabelColor = normalLabelColor.withAlphaComponent(disabledAlpha)
            outlineColor = normalLabelColor.withAlphaComponent(disabledAlpha)
        }
        
        self.init(textColor: textColor,
                  floatingLabelColor: floatingLabelColor,
                  normalLabelColor: normalLabelColor,
                  outlineColor: outlineColor)
    }
    
    /// Creates a new color model.
    /// - Parameters:
    ///   - textColor: Text color
    ///   - floatingLabelColor: Floating label color
    ///   - normalLabelColor: Normal label color
    ///   - outlineColor: Outline line color
    public init(textColor: UIColor, floatingLabelColor: UIColor, normalLabelColor: UIColor, outlineColor: UIColor) {
        self.textColor = textColor
        self.floatingLabelColor = floatingLabelColor
        self.normalLabelColor = normalLabelColor
        self.outlineColor = outlineColor
    }
}

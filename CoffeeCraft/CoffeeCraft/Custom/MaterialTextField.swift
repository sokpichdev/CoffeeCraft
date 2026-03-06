//
//  MaterialTextField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/2/25.
//
import SwiftUI
import UIKit

extension MaterialTextFeild {
    /// Possible behaviors for the label
    public enum LabelBehavior {
        case floats, disappears
    }
    
    /// Possible states for the text field
    public enum XState {
        case normal, editing, disabled, error
        
        static func with(isEnabled: Bool, isEditing: Bool, isError: Bool) -> XState {
            if isEnabled {
                return isError ? .error : isEditing ? .editing :  .normal
            }
            return .disabled
        }
    }
    
    // MARK: - UITextField Layout Overrides
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
//        let rightViewWidth = rightView?.frame.width ?? 0
        return CGRect(
            x: leftView == nil ? leftPadding : leftPaddingWithImage,
            y: superRect.origin.y,
            width: UIScreen.main.bounds.width - 32 - leftPaddingWithImage - 60,
            height: superRect.height
        )
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        return CGRect(x: leftView == nil ? leftPadding : leftPaddingWithImage,
                      y: superRect.origin.y,
                      width: UIScreen.main.bounds.width - 32 - leftPaddingWithImage - 60,
                      height: superRect.height)
    }
    
    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.leftViewRect(forBounds: bounds)
        return CGRect(x: 8, y: superRect.origin.y, width: 20, height: superRect.height)
    }
    
    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.rightViewRect(forBounds: bounds)
        return CGRect(x: superRect.origin.x - 8, y: superRect.origin.y, width: 60, height: superRect.height)
    }

    override public func borderRect(forBounds bounds: CGRect) -> CGRect {
        return .zero
    }
    
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if shouldPlaceholderBeVisible {
            return super.placeholderRect(forBounds: bounds)
        }
        return .zero
    }
    
    override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: frame.width - clearButtonSideLength - rightPadding,
                      y: (frame.height - clearButtonSideLength) / 2,
                      width: clearButtonSideLength,
                      height: clearButtonSideLength)
    }
    
    // MARK: - UITextField drawing overrides
    override public func drawPlaceholder(in rect: CGRect) {
        if shouldPlaceholderBeVisible {
            super.drawPlaceholder(in: rect)
        }
    }
    
    // MARK: - Accessors
    /// Set the color model for the specified state.
    /// - Parameters:
    ///   - colorModel: Color model
    ///   - state: State
    public func setColorModel(_ colorModel: ColorModel, for state: XState) {
        colorModels[state] = colorModel
//        if state == .normal {
//            colorModels[state] = ColorModel(textColor: UIColor(Color.textPrimary),
//                                                                                        floatingLabelColor: UIColor(Color.textFieldLabel),
//                                                                                        normalLabelColor: UIColor(Color.textMuted),
//                                                                                        outlineColor: UIColor.textFieldBorder)
//        } else if state == .editing {
//            colorModels[state] = ColorModel(textColor: UIColor(Color.textPrimary),
//                                                                                        floatingLabelColor: UIColor(Color.textFieldLabel),
//                                                                                        normalLabelColor: UIColor(Color.textMuted),
//                                                                                        outlineColor: UIColor.textFieldBorder)
//        } else if state == .error {
//            colorModels[state] = ColorModel(textColor: UIColor(Color.textPrimary),
//                                                       floatingLabelColor: UIColor(Color.accentPrimary),
//                                                       normalLabelColor: .textFieldError,
//                                                       outlineColor: UIColor.textFieldError)
//        } else {
//            colorModels[state] = ColorModel(with: .disabled)
//        }
        setNeedsLayout()
//        setNeedsFocusUpdate()
    }
    
    /// Set the outline line width for the specified state.
    /// - Parameters:
    ///   - outlineLineWidth: Outline line width
    ///   - state: State
    public func setOutlineLineWidth(_ outlineLineWidth: CGFloat, for state: XState) {
        outlineLineWidths[state] = outlineLineWidth
        setNeedsLayout()
    }
    
    // MARK: - UIView overrides
    override public func layoutSubviews() {
        preLayoutSubviews()
        super.layoutSubviews()
        postLayoutSubviews()
    }
    
    private func setUpOutlineSublayer() {
        outlineSublayer.fillColor = UIColor.clear.cgColor
        outlineSublayer.lineWidth = outlineLineWidth
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: 45)
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNeedsLayout()
    }
}

public class MaterialTextFeild: UITextField {
    private enum LabelPosition {
        case none, floating, normal
        static func with(hasLabelText: Bool, hasText: Bool, canLabelFloat: Bool, isEditing: Bool) -> LabelPosition {
            if hasLabelText {
                if isEditing || hasText {
                    return canLabelFloat ? .floating : .none
                } else {
                    return .normal
                }
            }
            return .none
        }
    }
    
    // MARK: - Properties
    /// The floating label.
    public var label = UILabel()
    public var isStarMark: Bool = false
    public var customState: XState = .normal
    private var star = UILabel()
    /// Defines the behavior of the label when the text field is editing.  The possible values are `floats` (default) or `disappears`.
    public var labelBehavior = LabelBehavior.floats
    /// The corner radius of the text field.
    public var containerRadius: CGFloat = Dimens.cornerRadius
    /// The current color model based on the current state.
    public var colorModel: ColorModel {
        return colorModels[textControlState] ?? ColorModel(with: textControlState)
    }
    /// The current outline line width based on the current state.
    public var outlineLineWidth: CGFloat {
        return outlineLineWidths[textControlState] ?? 1.0
    }
    
    private var textControlState: XState {
       let xx =  XState.with(isEnabled: isEnabled, isEditing: isEditing, isError: isValidate)
        customState = xx
        return xx
    }
    private var labelPosition: LabelPosition {
      let xx =  LabelPosition.with(hasLabelText: !(label.text?.isEmpty ?? true),
                           hasText: !(text?.isEmpty ?? true),
                           canLabelFloat: labelBehavior == .floats,
                           isEditing: isEditing)
 
        return xx
    }
    private var colorModels: [XState: ColorModel] = [
        .normal: ColorModel(with: .normal),
        .editing: ColorModel(with: .editing),
        .disabled: ColorModel(with: .disabled),
        .error: ColorModel(with: .error)
    ]
    private var outlineLineWidths: [XState: CGFloat] = [
        .normal: 1.0,
        .editing: 1.0,
        .disabled: 1.0,
        .error: 1.0
    ]
    private var shouldPlaceholderBeVisible: Bool {
        let hasPlaceholder = !(placeholder?.isEmpty ?? true)
        let hasText = !(text?.isEmpty ?? true)
        return hasPlaceholder && !hasText && labelPosition != .normal
    }
    private var normalFont: UIFont {
        UIFont.systemFont(ofSize: 12)
    }
    private var floatingFont: UIFont {
        let font = normalFont
        return font.withSize(font.pointSize * 0.8)
    }
    
    private var outlineSublayer = CAShapeLayer()
    private var labelFrame = CGRect.zero
    private var starFrame = CGRect.zero
    
    // MARK: - Constants
    
    private let animationDuration: TimeInterval = 0.15
    private let leftPadding: CGFloat = 117
    private var rightPadding: CGFloat = 0
    private let clearButtonSideLength: CGFloat = 24
    private let floatingLabelOutlineSidePadding: CGFloat = 4
    private var leftPaddingWithImage: CGFloat = 40
    
    public func updateRightPadding(withImage padding: CGFloat) {
        rightPadding = padding
        setNeedsLayout()
    }
    public func updateLeftPadding(withImage padding: CGFloat) {
        leftPaddingWithImage = padding
        setNeedsLayout()
    }
    // MARK: - Object lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initTextField()
    }
    
    private func initTextField() {
        setUpLabel()
        setUpOutlineSublayer()
    }
    
    // MARK: - View setup
    private func setUpLabel() {
        addSubview(label)
        star.text = "*"
        star.textColor = .red
        addSubview(star)
    }
    
    // MARK: - Layout
    private func preLayoutSubviews() {
        applyColors()
        switch labelPosition {
        case .none:
            self.labelFrame = .zero
            self.starFrame = .zero
        case .normal:
            self.labelFrame = labelFrameNormal
            self.starFrame = starFrameNormal
        case .floating:
            self.labelFrame = labelFrameFloating
            self.starFrame = starFrameFloating
        }
    }
    
    private func postLayoutSubviews() {
        label.isHidden = labelPosition == .none
        animateLabel()
        applyStyle()
    }
    
    // MARK: - Label
    private var labelFrameNormal: CGRect {
        let rect = textRect(forBounds: bounds)
        let labelMinX = rect.minX
        let labelMaxX = rect.maxX
        let maxWidth = labelMaxX - labelMinX
        let size = floatingLabelSize(with: label.text ?? "", maxWidth: maxWidth, font: normalFont)
        let originX = labelMinX
        let originY = rect.midY - (0.5 * size.height)
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
    private var starFrameNormal: CGRect {
        let rect = textRect(forBounds: bounds)
        let labelMinX = rect.minX
        let labelMaxX = rect.maxX
        let maxWidth = labelMaxX - labelMinX
        let size = floatingLabelSize(with: label.text ?? "", maxWidth: maxWidth, font: normalFont)
        let starSize = floatingLabelSize(with: "*", maxWidth: maxWidth, font: normalFont)
        let originY = rect.midY - (0.5 * size.height)
        return CGRect(x: leftView == nil ? size.width+117 : size.width+leftPaddingWithImage, y: originY, width: starSize.width, height: starSize.height)
    }
    
    private var labelFrameFloating: CGRect {
        let rect = textRect(forBounds: bounds)
        let labelMinX = 22.0 // rect.minX
        let labelMaxX = rect.maxX
        let maxWidth = labelMaxX - labelMinX
        let size = floatingLabelSize(with: label.text ?? "", maxWidth: maxWidth, font: floatingFont)
        let originX = labelMinX
        let originY = 0 - (0.5 * floatingFont.lineHeight)
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
    private var starFrameFloating: CGRect {
        let rect = textRect(forBounds: bounds)
        let labelMinX = leftView == nil ? rect.minX : rect.minX-35
        let labelMaxX = rect.maxX
        let maxWidth = labelMaxX - labelMinX
        let size = floatingLabelSize(with: label.text ?? "", maxWidth: maxWidth, font: floatingFont)
        let starSize = floatingLabelSize(with: "*", maxWidth: maxWidth, font: floatingFont)
        let originY = 0 - (0.5 * floatingFont.lineHeight)
        return CGRect(x: size.width+22,
                      y: originY,
                      width: starSize.width,
                      height: starSize.height)
    }
    
    private func floatingLabelSize(with placeholder: String, maxWidth: CGFloat, font: UIFont) -> CGSize {
        let fittingSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        var rect = (placeholder as NSString).boundingRect(with: fittingSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        rect.size.height = font.lineHeight
        return rect.size
    }
    
    private func animateLabel() {
        // MARK: Improve animations
        let animations = {
            switch self.labelPosition {
            case .floating:
                self.label.alpha = 1
                self.label.font = self.floatingFont
                self.star.font = self.floatingFont
            case .normal:
                self.label.alpha = 1
                self.label.font = self.normalFont
                self.star.font = self.normalFont
            case .none:
                self.label.alpha = 0
                self.star.alpha = 0
            }
            self.label.frame = self.labelFrame
            self.star.frame = self.isStarMark ? self.starFrame : .zero
        }
        let shouldPerformAnimation = !label.frame.equalTo(.zero)
        
        if shouldPerformAnimation {
            UIView.animate(withDuration: animationDuration, animations: animations)
        } else {
            animations()
        }
    }
    
    // MARK: - Coloring and style
    private func applyColors() {
        let labelColor: UIColor
        if customState == .editing {
                    switch labelPosition {
                    case .none:
                        labelColor = .clear
                    case .normal:
                        labelColor = colorModel.normalLabelColor
                    case .floating:
                        labelColor = colorModel.floatingLabelColor
                    }
                    label.textColor = labelColor
                } else if customState == .normal {
                    switch labelPosition {
                    case .none:
                        labelColor = .clear
                    case .normal:
                        labelColor = colorModel.normalLabelColor
                    case .floating:
                        labelColor = colorModel.floatingLabelColor
                    }
                    label.textColor = labelColor
                } else if customState == .error {
                    switch labelPosition {
                    case .none:
                        labelColor = .clear
                    case .normal:
                        labelColor = colorModel.normalLabelColor
                    case .floating:
                        labelColor = colorModel.normalLabelColor
                    }
                    label.textColor = labelColor
                } else if customState == .disabled {
                    switch labelPosition {
                    case .none:
                        labelColor = .clear
                    case .normal:
                        labelColor = colorModel.normalLabelColor
                    case .floating:
                        labelColor = colorModel.normalLabelColor
                    }
                    label.textColor = labelColor
                }
    }
    
    private func applyStyle() {
        let path = outlinePath(labelFrame: labelFrame, lineWidth: outlineLineWidth,
                               cornerRadius: containerRadius, isLabelFloating: labelPosition == .floating)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        outlineSublayer.path = path.cgPath
        outlineSublayer.lineWidth = outlineLineWidth
        CATransaction.commit()
        outlineSublayer.fillColor = backgroundColor?.cgColor
        outlineSublayer.strokeColor = colorModel.outlineColor.cgColor
        
        if outlineSublayer.superlayer != layer {
            layer.insertSublayer(outlineSublayer, at: 0)
        }
    }
    
    private func outlinePath(labelFrame: CGRect, lineWidth: CGFloat,
                             cornerRadius: CGFloat, isLabelFloating: Bool) -> UIBezierPath {
        let path = UIBezierPath()
        let textFieldWidth = bounds.width
        let sublayerMinY = CGFloat.zero
        let sublayerMaxY = bounds.height
        
        let startingPoint = CGPoint(x: cornerRadius, y: sublayerMinY)
        let topRightCornerPoint1 = CGPoint(x: textFieldWidth - cornerRadius, y: sublayerMinY)
        path.move(to: startingPoint)
        if isLabelFloating {
            let leftLineBreak = labelFrame.minX - floatingLabelOutlineSidePadding
            let rightLineBreak = labelFrame.maxX + floatingLabelOutlineSidePadding
            let rightLineStarBreak = labelFrame.maxX + floatingLabelOutlineSidePadding + 5
            path.addLine(to: CGPoint(x: leftLineBreak, y: sublayerMinY))
            path.move(to: CGPoint(x: self.isStarMark ? rightLineStarBreak : rightLineBreak, y: sublayerMinY))
            path.addLine(to: CGPoint(x: self.isStarMark ? rightLineStarBreak : rightLineBreak, y: sublayerMinY))
        } else {
            path.addLine(to: topRightCornerPoint1)
        }
        
        let topRightCornerPoint2 = CGPoint(x: textFieldWidth, y: sublayerMinY + cornerRadius)
        path.addTopRightCorner(from: topRightCornerPoint1, to: topRightCornerPoint2, with: cornerRadius)
        
        let bottomRightCornerPoint1 = CGPoint(x: textFieldWidth, y: sublayerMaxY - cornerRadius)
        let bottomRightCornerPoint2 = CGPoint(x: textFieldWidth - cornerRadius, y: sublayerMaxY)
        path.addLine(to: bottomRightCornerPoint1)
        path.addBottomRightCorner(from: bottomRightCornerPoint1, to: bottomRightCornerPoint2, with: cornerRadius)
        
        let bottomLeftCornerPoint1 = CGPoint(x: cornerRadius, y: sublayerMaxY)
        let bottomLeftCornerPoint2 = CGPoint(x: 0, y: sublayerMaxY - cornerRadius)
        path.addLine(to: bottomLeftCornerPoint1)
        path.addBottomLeftCorner(from: bottomLeftCornerPoint1, to: bottomLeftCornerPoint2, with: cornerRadius)
        
        let topLeftCornerPoint1 = CGPoint(x: 0, y: sublayerMinY + cornerRadius)
        let topLeftCornerPoint2 = CGPoint(x: cornerRadius, y: sublayerMinY)
        path.addLine(to: topLeftCornerPoint1)
        path.addTopLeftCorner(from: topLeftCornerPoint1, to: topLeftCornerPoint2, with: cornerRadius)
        
        return path
    }
}

class Dimens {
    // for all
    static let mediumPadding: CGFloat = 12
    static let largePadding: CGFloat = 16
    static let extraLargePadding: CGFloat = 20
    
    static let cornerRadius: CGFloat = 16
    static let largeCornerRadius: CGFloat = 16
    
    static let gaps: CGFloat = 10
    
    static let niuniuDealerCardHeight = ((((UIScreen.screenWidth - 32 ) / 2) - 20) / 10) * 4
    static let niuniucardHeight = ((UIScreen.screenWidth - 60) / 10) * 4
    static let lightNiuCardHeight = ((UIScreen.screenWidth - 60) / 24) * 6 + 30
    static let bigRoadMapCardHeight = ((UIScreen.screenWidth - 60) / 16) * 6
    static let dealerCardHeight = ((((UIScreen.screenWidth - 32) / 2) - 20) / 16) * 6
    static let lightCardHeight = ((((UIScreen.screenWidth - 78) / 2)) / 7) * 6
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

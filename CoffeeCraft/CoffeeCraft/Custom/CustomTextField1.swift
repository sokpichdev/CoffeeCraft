//
//  CustomTextField1.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/29/25.
//
import UIKit
import SwiftUI
import Combine

struct CustomTextField1<TrailingView: View>: View {
    @Binding var text: String
    var placeHolder: String
    var charLimit: Int = 254
    var keyboardType: UIKeyboardType = .default
    var fieldType: TextFieldType = .normal
    var isAutoCorrect: Bool = true
    var isStarMark: Bool = false
    var isFormDeposit: Bool = false
    var leadingIcon: ImageResource?
    var trailingIcon: ImageResource?
    var trailingView: TrailingView?
    var backgroundColor: Color?
    @Binding var isValidate: Bool
    var validateText: String = ""
    var isDisable: Bool = false
    var isReadOnly: Bool = false
    var countryText: String?
    var isAutoCapitalize: UITextAutocapitalizationType = .sentences
    var onTextChange: ((String) -> Void)?
    var onSelectCountry: ((String) -> Void)?
    var onTap: (() -> Void)?
    var onTapCountry: (() -> Void)?
    @State var textField = MaterialTextFeild()
    @State var eyeToggle = false
    @State var isPresentCountry = false
    @State var isFocus = false
    @State var update = false
    @State var showValidate = false
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                UITextFieldWrapper1(
                    fieldtype: fieldType,
                    keyboardType: keyboardType,
                    placerHolder: placeHolder,
                    isAutoCorrect: isAutoCorrect,
                    isStarMark: isStarMark,
                    leadingIcon: leadingIcon,
                    trailingIcon: trailingIcon,
                    isAutoCapitalize: isAutoCapitalize,
                    isDisable: isDisable,
                    isReadOnly: isReadOnly,
                    text: $text,
                    textField: $textField,
                    isFocus: $isFocus,
                    showValidate: isValidate, trailingView: trailingView)
                .onChange(of: text) { value, _ in
                    onTextChange?(value)
                }
                .onReceive(Just(text)) { newString in
                    guard charLimit > 0, newString.count > charLimit else { return }

                    DispatchQueue.main.async {
                        text = String(newString.prefix(charLimit))
                    }
                }
                .frame(height: 45)
                .background(RoundedRectangle(cornerRadius: 10).inset(by: 0.5).fill(isReadOnly ? .disableTextfieldBG : (backgroundColor ?? .textfieldBG)))
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            onTap?()
                        }
                )
            }
//            .overlay {
//                HStack {
//                    Spacer()
//                    if trailingView != nil {
//                        self.trailingView
//                            .background(.textfieldBG)
//                            .frame(height: 45)
//                            .padding(.trailing, 5)
//                            .padding(.leading, 5)
//                    }
//                }
//            }
            .overlay {
                if leadingIcon == nil {
                    HStack {
                        Button {
                            onTapCountry?()
                        } label: {
                            Text(countryText ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(.commonText)
                                .padding(.leading, leadingIcon == nil ? 8 : 20)
                            
                            Image(.arrowDown)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                                .padding(.trailing, 16)
                            
                            Divider()
                                .frame(height: 20)
                                .background(.commonGray)
                        }
                        .padding()
                        .background(Color.clear)
                        .disabled(isDisable || isReadOnly)
                        Spacer()
                    }
                }
            }
            .overlay(
                HStack {
                    Spacer()
                    if fieldType == .password {
                        Button {
                            eyeToggle.toggle()
                            textField.isSecureTextEntry = !eyeToggle
                        } label: {
                            Image(eyeToggle ? .eyeOpen : .eyeClose)
                                .padding(10)
                        }
                    }
                }
            )
            .onTapGesture {
                self.textField.becomeFirstResponder()
            }
            if showValidate {
                Text(validateText)
                    .font(.system(size: 12))
                    .foregroundColor(Color.textFieldError)
            }
        }
        .onChange(of: isValidate) {
            if !isValidate {  // Show error when NOT valid
                showValidate = true
                textField.isValidate = true
            } else {
                showValidate = false
                textField.isValidate = false
            }
        }
        .onChange(of: isFocus) {
            if !isFocus {
                if !isValidate { // how error when NOT valid
                    showValidate = true
                    textField.isValidate = true
                } else {
                    showValidate = false
                    textField.isValidate = false
                }
            }
        }
    }
}

struct UITextFieldWrapper1<TrailingView: View>: UIViewRepresentable {
    var fieldtype: TextFieldType = .normal
    var keyboardType: UIKeyboardType = .default
    var placerHolder: String
    var isAutoCorrect: Bool
    var isStarMark: Bool
    var leadingIcon: ImageResource?
    var trailingIcon: ImageResource?
    var isAutoCapitalize: UITextAutocapitalizationType = .sentences
    var isDisable: Bool
    var isReadOnly: Bool
    @Binding var text: String
    @Binding var textField: MaterialTextFeild
    @Binding var isFocus: Bool
    var showValidate: Bool
    var trailingView: TrailingView?
    func makeUIView(context: Context) -> MaterialTextFeild {
        textField.delegate = context.coordinator
        textField.font = .systemFont(ofSize: 14)
        textField.keyboardType = keyboardType
        textField.label.text = placerHolder
//        textField.label.font =  UIFont.systemFont(ofSize: 11)
        textField.isStarMark = isStarMark
        textField.autocapitalizationType = isAutoCapitalize
        textField.autocorrectionType = isAutoCorrect ? .yes : .no
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setOutlineLineWidth(1, for: .editing)
        textField.label.numberOfLines = 2
        
        textField.setColorModel(ColorModel(textColor: UIColor(Color.primaryTextColor),
                                           floatingLabelColor: UIColor(Color.gray),
                                           normalLabelColor: UIColor(Color.placeHolderColor),
                                           outlineColor: .textFieldBorder), for: .normal)
        textField.setColorModel(ColorModel(textColor: UIColor(Color.primaryTextColor),
                                           floatingLabelColor: .activeTF,
                                           normalLabelColor: .activeTF,
                                           outlineColor: .activeTF), for: .editing)
        textField.setColorModel(ColorModel(textColor: UIColor(Color.primaryTextColor),
                                           floatingLabelColor: .textFieldError,
                                           normalLabelColor: .textFieldError,
                                           outlineColor: .textFieldError), for: .error)
        textField.setColorModel(ColorModel(with: .disabled), for: .disabled)
        
        if isDisable || isReadOnly {
            textField.isUserInteractionEnabled = false
        } else {
            textField.isUserInteractionEnabled = true
        }
        textField.updateLeftPadding(withImage: 56)
        if leadingIcon != nil {
            let left = UIImageView(image: UIImage(resource: leadingIcon!))
            left.contentMode = .scaleAspectFit
            
            let padding: CGFloat = 10 // This is the padding amount
            
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 24 + padding, height: 24))
            
            left.frame = CGRect(x: padding, y: 0, width: 24, height: 24)
            
            containerView.addSubview(left)
            
            textField.leftView = containerView
            textField.leftViewMode = .always
            textField.leftView?.contentMode = .scaleAspectFit
            
        }
//
//        if trailingIcon != nil {
//            let image = UIImageView(image: UIImage(resource: trailingIcon!))
//            image.contentMode = .scaleAspectFit
//            
//            let padding: CGFloat = 10 // This is the padding amount
//            
//            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
//            
//            image.frame = CGRect(x: -padding, y: 0, width: 16, height: 16)
//            
//            containerView.addSubview(image)
//            
////            textField.leftView = containerView
//            textField.rightView = containerView
//            textField.rightViewMode = .always
//            textField.rightView?.contentMode = .scaleAspectFit
//        }
//        // Set up the trailing view (rightView) if provided
              if let trailingView = trailingView, !(trailingView is EmptyView) {
                  let hostingController = UIHostingController(rootView: trailingView)
                  hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                  hostingController.view.backgroundColor = .clear
                  // Container view to wrap the SwiftUI view
                  let containerView = UIView()
                  containerView.addSubview(hostingController.view)
                  containerView.backgroundColor = .clear
                  NSLayoutConstraint.activate([
                      hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                      hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                      hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                      hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                  ])

                  textField.rightView = containerView
                  textField.rightView?.backgroundColor = .clear
                  textField.rightViewMode = .always
              }

        if fieldtype == .password {
            textField.isSecureTextEntry = true
            let image = UIView()
            textField.rightView = image
            textField.rightViewMode = .always
            textField.textContentType = .oneTimeCode
        } else if fieldtype == .withTrailingButton {
            textField.updateRightPadding(withImage: 90)
        } else if fieldtype == .email {
            textField.textContentType = .oneTimeCode
        }
        return textField
    }

    func updateUIView(_ uiView: MaterialTextFeild, context: Context) {
        if uiView.label.text != placerHolder {
               uiView.label.text = placerHolder
        }

        if uiView.text != text {
            uiView.text = text
        }
        if !isFocus {
            uiView.isValidate = showValidate && uiView.text?.count ?? 0 > 0
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isFocus: $isFocus, showValidate: showValidate)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocus: Bool
        var showValidate: Bool

        init(text: Binding<String>, isFocus: Binding<Bool>, showValidate: Bool) {
            _text = text
            _isFocus = isFocus
            self.showValidate = showValidate
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            let newText = textField.text ?? ""
            // Avoid redundant publishes and defer to the next runloop to escape view update phase
            guard newText != text else { return }
            DispatchQueue.main.async { [weak self] in
                // Double-check after deferral to avoid racing with SwiftUI updates
                if self?.text != newText {
                    self?.text = newText
                }
            }
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self] in
                self?.isFocus = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self] in
                self?.isFocus = false
            }
        }
    }
}

/// For text Field input type
enum TextFieldType {
    case emailOrPhone
    case email
    case password
    case normal
    case mobileNo
    case otp
    case withTrailingButton
}


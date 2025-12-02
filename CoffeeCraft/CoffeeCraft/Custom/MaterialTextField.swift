//
//  MaterialTextField.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/2/25.
//
import SwiftUI
import UIKit
import Combine

struct MaterialTextField<Leading: View, Trailing: View>: View {
    @Binding var text: String
    var countryCode: String = ""
    var placeholder: String
    var charLimit: Int = 254
    var keyboardType: UIKeyboardType = .default
    var fieldtype: TextFieldType = .normal
    var isDisable: Bool = false
    var isError: Bool = false
    var errorText: String = ""
    var isAutoCapitalize: UITextAutocapitalizationType = .sentences
    var leading: Leading?
    var trailing: Trailing?
    var onTextChanged: ((String) -> Void)?
    
    @FocusState private var focused: Bool
    @State var eyeToggle = false
    @State var textField = UITextField()
    @State private var keepFloating = false
    
    // MARK: - Has Leading & Trailing
    init(
        text: Binding<String>,
        countryCode: String = "",
        placeholder: String,
        charLimit: Int = 254,
        keyboardType: UIKeyboardType = .default,
        fieldtype: TextFieldType = .normal,
        isDisable: Bool = false,
        isError: Bool = false,
        errorText: String = "",
        isAutoCapitalize: UITextAutocapitalizationType = .sentences,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing,
        onTextChanged: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.countryCode = countryCode
        self.placeholder = placeholder
        self.charLimit = charLimit
        self.keyboardType = keyboardType
        self.fieldtype = fieldtype
        self.isDisable = isDisable
        self.isError = isError
        self.errorText = errorText
        self.isAutoCapitalize = isAutoCapitalize
        self.leading = leading()
        self.trailing = trailing()
        self.onTextChanged = onTextChanged
    }
    
    // MARK: - Has Leading, No Trailing
    init(
        text: Binding<String>,
        countryCode: String = "",
        placeholder: String,
        isDisable: Bool = false,
        isError: Bool = false,
        errorText: String = "",
        charLimit: Int = 254,
        keyboardType: UIKeyboardType = .default,
        isAutoCapitalize: UITextAutocapitalizationType = .sentences,
        fieldtype: TextFieldType = .normal,
        @ViewBuilder leading: () -> Leading,
        onTextChanged: ((String) -> Void)? = nil
    ) where Trailing == EmptyView {
        self._text = text
        self.countryCode = countryCode
        self.placeholder = placeholder
        self.charLimit = charLimit
        self.keyboardType = keyboardType
        self.fieldtype = fieldtype
        self.isDisable = isDisable
        self.isError = isError
        self.errorText = errorText
        self.isAutoCapitalize = isAutoCapitalize
        self.leading = leading()
        self.trailing = nil
        self.onTextChanged = onTextChanged
    }
    
    // MARK: - No Leading, Has Trailing
    init(
        text: Binding<String>,
        countryCode: String = "",
        placeholder: String,
        charLimit: Int = 254,
        keyboardType: UIKeyboardType = .default,
        fieldtype: TextFieldType = .normal,
        isDisable: Bool = false,
        isError: Bool = false,
        errorText: String = "",
        isAutoCapitalize: UITextAutocapitalizationType = .sentences,
        @ViewBuilder trailing: () -> Trailing,
        onTextChanged: ((String) -> Void)? = nil
    ) where Leading == EmptyView {
        self._text = text
        self.countryCode = countryCode
        self.placeholder = placeholder
        self.charLimit = charLimit
        self.keyboardType = keyboardType
        self.fieldtype = fieldtype
        self.isDisable = isDisable
        self.isError = isError
        self.errorText = errorText
        self.isAutoCapitalize = isAutoCapitalize
        self.leading = nil
        self.trailing = trailing()
        self.onTextChanged = onTextChanged
    }
    
    // MARK: - No Leading, No Trailing
    init(
        text: Binding<String>,
        countryCode: String = "",
        placeholder: String,
        charLimit: Int = 254,
        keyboardType: UIKeyboardType = .default,
        fieldtype: TextFieldType = .normal,
        isDisable: Bool = false,
        isError: Bool = false,
        errorText: String = ""
    ) where Leading == EmptyView, Trailing == EmptyView {
        self._text = text
        self.countryCode = countryCode
        self.placeholder = placeholder
        self.charLimit = charLimit
        self.keyboardType = keyboardType
        self.fieldtype = fieldtype
        self.isDisable = isDisable
        self.isError = isError
        self.errorText = errorText
        self.leading = nil
        self.trailing = nil
    }
    
    var labelFloating: Bool {
        focused || keepFloating || !text.isEmpty
    }
    
    var borderColor: Color {
        if isError { return .red }
//        if focused { return .blue }
        return .gray.opacity(0.5)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: 1)
                    .background(Color(.systemBackground))
                
                if labelFloating {
                    Text(placeholder)
                        .font(.system(size: 14))
                        .foregroundColor(isError ? .red : .gray)
                        .padding(.horizontal, 6)
                        .background(Color(.systemBackground))
                        .offset(x: 12, y: -28)
                        .scaleEffect(1.0)
//                        .matchedGeometryEffect(id: "placeholder", in: animation)
                }
                
                HStack(spacing: 0) {
                    
                    if let leading { leading }
                    
                    ZStack(alignment: .leading) {
                        
                        if !labelFloating {
                            Text(placeholder)
                                .font(.customFont(size: 14, weight: .regular))
                                .foregroundColor(.gray)
//                                .matchedGeometryEffect(id: "placeholder", in: animation)
                                .scaleEffect(1.0)
                        }
                        if fieldtype == .password && !eyeToggle {
                            SecureField("", text: $text)
                                .font(.customFont(size: 14, weight: .regular))
                                .focused($focused)
                                .animation(.easeInOut(duration: 0.22), value: labelFloating)
                                .keyboardType(keyboardType)
                                .textContentType(.oneTimeCode)
                        } else {
                            TextField("", text: $text)
                                .focused($focused)
                                .font(.customFont(size: 14, weight: .regular))
                                .animation(.easeInOut(duration: 0.22), value: labelFloating)
                                .keyboardType(keyboardType)
                                .disabled(isDisable)
                                .autocapitalization(isAutoCapitalize)
                        }
                    }
                    .padding(.leading, 12)
                    
                    if let trailing {
                        trailing
                    } else if fieldtype == .password {
                        Button {
                            eyeToggle.toggle()
                        } label: {
                            Image(eyeToggle ? .eyeOpen : .eyeClose)
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 56)
            
            if isError {
                Text(errorText)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: text) { value in
            onTextChanged?(value)
        }
        .onChange(of: keyboardType) { _ in
            keepFloating = true
            Utilize.hideKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focused = true
                keepFloating = false
            }
        }
        .onReceive(Just(text)) { newString in
            if charLimit > 0 {
                if newString.count > charLimit {
                    text = String(newString.prefix(charLimit))
                }
            }
        }
    }
}

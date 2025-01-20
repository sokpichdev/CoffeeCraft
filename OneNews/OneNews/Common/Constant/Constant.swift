//
//  Constant.swift
//  OneNews
//
//  Created by Sok Pich on 1/20/25.
//

import SwiftUI

enum FontSize {
    case small
    case normal
    case medium
    case large
    case huge
    case other(CGFloat)

    var fontSize: CGFloat {
        switch self {
        case .small:
            return 10
        case .normal:
            return 12
        case .medium:
            return 14
        case .large:
            return 16
        case .huge:
            return 20
        case .other(let customSize):
            return customSize
        }
    }
}

class Dimens {
    // for all
    static let mediumPadding: CGFloat = 12
    static let largePadding: CGFloat = 16
    static let extraLargePadding: CGFloat = 20
    
    static let cornerRadius: CGFloat = 10
    static let largeCornerRadius: CGFloat = 16.0
    
    static let gaps: CGFloat = 10
}

enum PasswordType {
    case password
    case confirmPassword
    case newPassword
    case currentPassword
}
enum AuthButtonType {
    case login
    case register
    case confirm
}


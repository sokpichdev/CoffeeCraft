//
//  Constants.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/16/25.
//

import SwiftUI

enum FirebaseEnvironment {
    case dev, sit, uat, prod
}

struct Constants {
    static var currentEnv: FirebaseEnvironment {
        #if Dev
        return .dev
        #elseif SIT
        return .sit
        #elseif UAT
        return .uat
        #else
        return .prod
        #endif
    }
}
extension FirebaseEnvironment: CustomStringConvertible {
    var description: String {
        switch self {
        case .dev: return "dev"
        default: return "dev"
        }
    }
}

var greetingText: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 5..<12: return "Good morning ☀️ Your brew awaits"
    case 12..<17: return "Good afternoon ☁️ Take a coffee break"
    case 17..<21: return "Good evening 🌙 Wind down with a cup"
    default: return "Hello! 🌙 Late night coffee?"
    }
}

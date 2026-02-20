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

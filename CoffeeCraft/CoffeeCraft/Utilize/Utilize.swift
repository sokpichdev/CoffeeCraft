//
//  Utilize.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/2/25.
//

import SwiftUI

class Utilize {
    static let shared = Utilize()
    
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

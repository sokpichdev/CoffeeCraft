//
//  UserPreference.swift
//  OneNews
//
//  Created by Sok Pich on 1/3/25.
//
import SwiftUI


class UserPreference {
    static let shared = UserPreference()
    private var defaults: UserDefaults = UserDefaults.standard
    
    private let isDarkMode = "isDarkMode"
    
    // MARK: Dark Mode
    func getIsDarkMode() -> Bool {
        guard let isDarkMode = defaults.object(forKey: isDarkMode) as? Bool else {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                self.setIsDarkMode(set: true)
                return true
            } else {
                self.setIsDarkMode(set: false)
                return false
            }
        }
        return isDarkMode
    }
    func setIsDarkMode(set: Bool) {
        defaults.set(set, forKey: isDarkMode)
    }
}

//
//  UserPreference.swift
//  OneNews
//
//  Created by Sok Pich on 1/3/25.
//
import SwiftUI

import Foundation
import SwiftUI

class UserPreference {
    static let shared = UserPreference()
    private var defaults: UserDefaults = UserDefaults.standard
    
    private let setUserData = "setUserData"
    private let isDarkMode = "isDarkMode"
    
    private let selectedLanguage = "selectedLanguage"
    private let setToken = "setToken"
    private let forceUpdateDate = "forceUpdateDate"
    
    
    func setToken(token: String) {
        defaults.set(token, forKey: setToken)
        defaults.synchronize()
    }
    func getToken() -> String {
        guard let token = defaults.object(forKey: setToken) as? String else {
            return ""
        }
        return token
    }
    
    // MARK: - Language Preferences
        
        // Set the selected language in UserDefaults
        func setSelectedLanguage(language: String) {
            defaults.set(language, forKey: selectedLanguage)
            defaults.synchronize()
        }
        
        // Get the selected language from UserDefaults
        func getSelectedLanguage() -> String {
            guard let language = defaults.object(forKey: selectedLanguage) as? String else {
                return "en" // Default to English if no language is set
            }
            return language
        }
    
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
    
    func resetDataOnLogout() {
        defaults.removeObject(forKey: setToken)
        defaults.removeObject(forKey: setUserData)
        defaults.synchronize()
    }
    
    func setForceUpdate(date: Date) {
        defaults.set(date, forKey: forceUpdateDate)
        defaults.synchronize()
    }
    
    func getForceUpdateDate() -> Date? {
        guard let date = defaults.object(forKey: forceUpdateDate) as? Date else {
            return nil
        }
        return date
    }
    
    func resetDataOnDeleteAccount() {
        defaults.removeObject(forKey: setToken)
        defaults.removeObject(forKey: setUserData)
        defaults.synchronize()
    }
    
}


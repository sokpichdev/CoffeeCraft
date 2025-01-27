//
//  LanguageManager.swift
//  Localization
//
//  Created by Sok Pich on 1/27/25.
//

import Foundation

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            Bundle.setLanguage(currentLanguage)
        }
    }

    init() {
        if let savedLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first {
            currentLanguage = savedLanguage
        } else {
            currentLanguage = Locale.current.languageCode ?? "en" // Default to system language or English
        }
    }
}

//
//  LanguageSelectionView.swift
//  OneNews
//
//  Created by Sok Pich on 1/27/25.
//

import SwiftUI

struct LanguageSelectionView: View {
    @StateObject private var languageManager = LanguageManager()
    
    var body: some View {
            VStack(spacing: 10) {
                Text("Hello".localized() + "one".localized())
                
                Spacer()
                
                HStack {
                    Button("English".localized()) {
                        languageManager.currentLanguage = "en"
                    }
                    .padding()
                    .background(languageManager.currentLanguage == "en" ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Khmer".localized()) {
                        languageManager.currentLanguage = "km-KH"
                    }
                    .padding()
                    .background(languageManager.currentLanguage == "km-KH" ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Chinese".localized()) {
                        languageManager.currentLanguage = "zh-Hant"
                    }
                    .padding()
                    .background(languageManager.currentLanguage == "zh-Hant" ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                }
            }
            .padding(.vertical, 30)
            .environmentObject(languageManager)
    }
}

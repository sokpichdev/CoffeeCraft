//
//  ContentView.swift
//  Localization
//
//  Created by Sok Pich on 1/27/25.
//
import SwiftUI
struct ContentView: View {
    @StateObject private var languageManager = LanguageManager()
    
    let company: String = "Apple"
    let one: Int = 1
    let ten: Int = 10
    let distance: Double = 1.234567
    @State var isNavigated2SecondView: Bool = false

    var body: some View {
        NavigationStack{
            VStack(spacing: 10) {
                Text("Hello".localized(with: company))
                
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
                        languageManager.currentLanguage = "km"
                    }
                    .padding()
                    .background(languageManager.currentLanguage == "km" ? Color.blue : Color.gray)
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
                //I would like to request [specific dates] off to spend Lunar New Year with my family
                Button(action: {
                    isNavigated2SecondView = true
                }) {
                    Text("GoToSecondView".localized())
                }
                .background(NavigationLink("", destination: SecondView(), isActive: $isNavigated2SecondView))
            }
            .padding(.vertical, 30)
            .environmentObject(languageManager)
        }
        
    }
}

extension String {
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

#Preview {
    ContentView()
}


struct SecondView: View {
    @EnvironmentObject private var languageManager: LanguageManager // Use the same LanguageManager

    var body: some View {
        Text("Hello".localized())
    }
}

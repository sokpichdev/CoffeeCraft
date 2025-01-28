//
//  ContentView.swift
//  Localization
//
//  Created by Sok Pich on 1/27/25.
//
import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var languageManager = LanguageManager()
    
    let one: Int = 1
    let ten: Int = 10
    let distance: Double = 1.234567
    @State var isNavigated2SecondView: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                
                Text(mobileHello.localized() + mobileONe.localized())
                
                Spacer()
                
                HStack {
                    Button(action: {
                        languageManager.currentLanguage = LanguageCode.english.rawValue
                    }) {
                        VStack {
                            Circle()
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(.english)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 4) // Adds a border
                                )
                                .shadow(radius: 5, y: 4) // Adds a shadow
                            Text(mobileEnglish.localized())
                            Spacer()
                            Image(.englishBg)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Align image to bottom
                        }
                        .frame(maxWidth: .infinity, maxHeight: 350)
                        .background(Color.white)
                        .clipShape(RoundedCornerShape(radius: 300, corners: [.topLeft, .topRight]))
                    }
                    
                    Button(action: {
                        languageManager.currentLanguage = LanguageCode.khmer.rawValue
                    }) {
                        VStack {
                            Circle()
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(.cambodia)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                )
                            Text(mobileKhmer.localized())
                            Spacer()
                            Image(.khmerBg)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Align image to bottom
                        }
                        .frame(maxWidth: .infinity, maxHeight: 350)
                        .background(Color.white)
                        .clipShape(RoundedCornerShape(radius: 300, corners: [.topLeft, .topRight]))
                    }
                    
                    Button(action: {
                        languageManager.currentLanguage = LanguageCode.chinese.rawValue
                    }) {
                        VStack {
                            Circle()
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(.china)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                )
                            Text(mobileChinese.localized())
                            Spacer()
                            Image(.chineseBg)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Align image to bottom
                        }
                        .frame(maxWidth: .infinity, maxHeight: 350)
                        .background(Color.white)
                        .clipShape(RoundedCornerShape(radius: 300, corners: [.topLeft, .topRight]))
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(Color.gray.opacity(0.2))
            .environmentObject(languageManager)
        }
    }
}

struct SecondView: View {
    let company: String = "Apple"
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        Text(mobileHello.localized(with: company))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

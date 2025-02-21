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
                    CountryButton(
                        languageCode: .english,
                        countryName: "English",
                        imageName: .english,
                        bgImageName: .englishBg,
                        languageManager: languageManager
                    )
                    
                    CountryButton(
                        languageCode: .khmer,
                        countryName: "Cambodia",
                        imageName: .cambodia,
                        bgImageName: .khmerBg,
                        languageManager: languageManager
                    )
                    
                    CountryButton(
                        languageCode: .chinese,
                        countryName: "China",
                        imageName: .china,
                        bgImageName: .chineseBg,
                        languageManager: languageManager
                    )
                }
                .padding(.horizontal, 16)
            }
            .background(Color.gray.opacity(0.2))
            .environmentObject(languageManager)
        }
    }
}

struct CountryButton: View {
    let languageCode: LanguageCode
    let countryName: String
    let imageName: ImageResource
    let bgImageName: ImageResource
    @ObservedObject var languageManager: LanguageManager
    
    var body: some View {
        Button(action: {
            languageManager.currentLanguage = languageCode.rawValue
        }) {
            VStack {
                CountryCircle(countryName: imageName)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(radius: 5, y: 4)
                Text(localizedText(for: languageCode))
                Spacer()
                Image(bgImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .padding(.top, 16)
            .frame(maxWidth: .infinity, maxHeight: 350)
            .background(Color.white)
            .clipShape(RoundedCornerShape(radius: 300, corners: [.topLeft, .topRight]))
        }
        .foregroundColor(.black)
    }
    
    private func localizedText(for languageCode: LanguageCode) -> String {
        switch languageCode {
        case .english:
            return mobileEnglish.localized()
        case .khmer:
            return mobileKhmer.localized()
        case .chinese:
            return mobileChinese.localized()
        }
    }
}

struct CountryCircle: View {
    var countryName: ImageResource
    
    var body: some View {
        Circle()
            .frame(width: 40, height: 40)
            .overlay(
                Image(countryName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            )
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

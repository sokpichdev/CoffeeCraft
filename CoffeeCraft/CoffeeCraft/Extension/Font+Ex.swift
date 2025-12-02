//
//  Font+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 12/2/25.
//
import SwiftUI

extension Font {
    static func customFont(
        _ font: AppFont = .nokora,
        size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        Font.custom(font.rawValue, size: size).weight(weight)
    }
}

extension Font {
    
    // MARK: - Titles
    static var customTitle: Font {
        .customFont(size: 28)
    }
    
    static var customTitle2: Font {
        .customFont(size: 22)
    }
    
    static var customTitle3: Font {
        .customFont(size: 20)
    }

    // MARK: - Body & Callout
    static var customBody: Font {
        .customFont(size: 17)
    }

    static var customCallout: Font {
        .customFont(size: 16)
    }
    
    // MARK: - Subheadline & Headline
    static var customSubheadline: Font {
        .customFont(size: 15)
    }
    
    static var customHeadline: Font {
        .customFont(size: 17).weight(.semibold)
    }
    
    // MARK: - Captions
    static var customCaption: Font {
        .customFont(size: 12)
    }
    
    static var customCaption2: Font {
        .customFont(size: 11)
    }
}


enum AppFont: String {
    case nokora = "Nokora"
    case roboto = "Roboto"
    case poppins = "Poppins"
    case montserrat = "Montserrat"
}

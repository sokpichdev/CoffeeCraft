//
//  CustomAttributedStringText.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 11/10/25.
//
import SwiftUI

struct CustomAttributedStringText: View {
    private let parts: [AttributedString]
    
    init(_ segments: TextSegment...) {
        var temp: [AttributedString] = []
        
        for (index, segment) in segments.enumerated() {
            var attributed = AttributedString(segment.text)
            
            // Apply modifiers
            if let color = segment.color { attributed.foregroundColor = color }
            if let font = segment.font { attributed.font = font }
            if let link = segment.link { attributed.link = link }
            if segment.underline { attributed.underlineStyle = Text.LineStyle.single }
            if segment.strikethrough { attributed.strikethroughStyle = Text.LineStyle.single }
            if segment.italic { attributed.font = (attributed.font ?? .body).italic() }
            
            // Append separator
            if index < segments.count - 1 {
                attributed.append(AttributedString(segment.newLine ? "\n" : " "))
            }
            
            temp.append(attributed)
        }
        
        self.parts = temp
    }
    
    var body: some View {
        Text(parts.reduce(AttributedString(""), +))
    }
}

// MARK: - Each segment
struct TextSegment {
    var text: String
    var color: Color? = nil
    var font: Font? = nil
    var link: URL? = nil
    var underline: Bool = false
    var strikethrough: Bool = false
    var italic: Bool = false
    var newLine: Bool = false
}

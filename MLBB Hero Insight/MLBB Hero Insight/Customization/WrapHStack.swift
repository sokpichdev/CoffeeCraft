//
//  WrapHStack.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/25/25.
//
import SwiftUI

struct WrapHStack<Data: RandomAccessCollection, Content: View, ID: Hashable>: View {
    let items: Data
    let idKey: KeyPath<Data.Element, ID>
    let content: (Data.Element) -> Content

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        let rowSpacing: CGFloat = 5
        let maxWidth = geometry.size.width

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: idKey) { item in
                content(item)
                    .padding(.horizontal, 4)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > maxWidth {
                            width = 0
                            height -= d.height + rowSpacing
                        }
                        let result = width
                        if item[keyPath: idKey] == items.last?[keyPath: idKey] {
                            width = 0 // Last one resets
                        } else {
                            width -= d.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item[keyPath: idKey] == items.last?[keyPath: idKey] {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewHeightKey.self, value: geometry.size.height)
        }
        .onPreferenceChange(ViewHeightKey.self) { binding.wrappedValue = $0 }
    }
}

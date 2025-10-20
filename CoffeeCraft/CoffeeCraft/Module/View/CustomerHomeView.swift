//
//  CustomerHomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CustomerHomeView: View {
    @StateObject private var productVM = ProductViewModel()
    @State private var selectedSectionID: String? = nil
    @State private var visibleSectionID: String? = nil
    @State private var isProgrammaticScroll = false

    var body: some View {
        HStack(spacing: 0) {
            // LEFT CATEGORY MENU
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(productVM.sections) { section in
                            Button(action: {
                                isProgrammaticScroll = true
                                withAnimation(.easeInOut) { selectedSectionID = section.id }
                            }) {
                                ZStack(alignment: .trailing) {
                                    HStack {
                                        Text(section.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(selectedSectionID == section.id ? .blue : .primary)
                                            .padding(.vertical, 10)
                                            .padding(.leading, 8)
                                        Spacer()
                                    }

                                    Rectangle()
                                        .fill(selectedSectionID == section.id ? Color.accentColor : Color.clear)
                                        .frame(width: 4)
                                        .cornerRadius(2)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.leading, 5)
                    .padding(.vertical, 10)
                }
                .frame(width: 120)
                .background(Color(.systemGray6))
            }

            Divider()

            // RIGHT SIDE ITEMS
            ScrollViewReader { contentProxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(productVM.sections) { section in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(section.name)
                                    .font(.title3.bold())
                                    .padding(.horizontal)
                                    .padding(.top, 8)

                                VStack(spacing: 10) {
                                    ForEach(section.items) { item in
                                        MenuItemRow(item: item)
                                            .id("\(section.id)_\(item.name)")
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: SectionOffsetKey.self,
                                        value: [section.id: geo.frame(in: .named("scroll")).minY]
                                    )
                                }
                            )
                            .id(section.id)
                        }
                    }
                    .padding(.bottom, 50)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(SectionOffsetKey.self) { values in
                    if !isProgrammaticScroll { updateVisibleSection(values: values) }
                }
                .onChange(of: selectedSectionID) { newValue in
                    if let id = newValue, isProgrammaticScroll {
                        withAnimation(.easeInOut) { contentProxy.scrollTo(id, anchor: .top) }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { isProgrammaticScroll = false }
                    }
                }
            }
        }
        .onChange(of: visibleSectionID) { newValue in
            selectedSectionID = newValue
        }
        .task {
            await productVM.fetchProducts()
            selectedSectionID = productVM.sections.first?.id
        }
    }

    private func updateVisibleSection(values: [String: CGFloat]) {
        let sorted = values.sorted { $0.value < $1.value }
        if let topSection = sorted.first?.key {
            visibleSectionID = topSection
        }
    }
}



// MARK: - Preference Key
struct SectionOffsetKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

//
//  DualScrollView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 10/16/25.
//
import SwiftUI

struct DualScrollView: View {
    // Example Data
    let sections: [SectionData] = [
            SectionData(id: "coffee", name: "Coffee", items: [
                MenuItem(name: "Espresso", price: 2.99, image: "cup.and.saucer.fill"),
                MenuItem(name: "Americano", price: 3.49, image: "cup.and.saucer.fill"),
                MenuItem(name: "Latte", price: 3.99, image: "cup.and.saucer.fill"),
                MenuItem(name: "Cappuccino", price: 4.29, image: "cup.and.saucer.fill"),
                MenuItem(name: "Mocha", price: 4.49, image: "cup.and.saucer.fill"),
                MenuItem(name: "Cold Brew", price: 4.79, image: "cup.and.saucer.fill")
            ]),
            
            SectionData(id: "tea", name: "Tea", items: [
                MenuItem(name: "Green Tea", price: 2.49, image: "leaf.fill"),
                MenuItem(name: "Black Tea", price: 2.59, image: "leaf.fill"),
                MenuItem(name: "Oolong Tea", price: 2.89, image: "leaf.fill"),
                MenuItem(name: "Chamomile Tea", price: 2.99, image: "leaf.fill"),
                MenuItem(name: "Matcha Latte", price: 3.49, image: "leaf.fill")
            ]),
            
            SectionData(id: "juice", name: "Juice", items: [
                MenuItem(name: "Orange Juice", price: 3.49, image: "drop.fill"),
                MenuItem(name: "Apple Juice", price: 3.29, image: "drop.fill"),
                MenuItem(name: "Mango Juice", price: 3.59, image: "drop.fill"),
                MenuItem(name: "Pineapple Juice", price: 3.49, image: "drop.fill"),
                MenuItem(name: "Carrot Juice", price: 3.19, image: "drop.fill")
            ]),
            
            SectionData(id: "smoothies", name: "Smoothies", items: [
                MenuItem(name: "Strawberry Banana", price: 4.99, image: "cup.and.saucer.fill"),
                MenuItem(name: "Mango Passion", price: 4.89, image: "cup.and.saucer.fill"),
                MenuItem(name: "Avocado Smoothie", price: 5.29, image: "cup.and.saucer.fill"),
                MenuItem(name: "Berry Blast", price: 4.79, image: "cup.and.saucer.fill")
            ]),
            
            SectionData(id: "milkshakes", name: "Milkshakes", items: [
                MenuItem(name: "Vanilla Milkshake", price: 4.49, image: "drop.fill"),
                MenuItem(name: "Chocolate Milkshake", price: 4.79, image: "drop.fill"),
                MenuItem(name: "Strawberry Milkshake", price: 4.69, image: "drop.fill"),
                MenuItem(name: "Oreo Milkshake", price: 5.19, image: "drop.fill")
            ]),
            
            SectionData(id: "desserts", name: "Desserts", items: [
                MenuItem(name: "Cheesecake", price: 4.99, image: "birthday.cake.fill"),
                MenuItem(name: "Brownie", price: 4.49, image: "birthday.cake.fill"),
                MenuItem(name: "Macaron", price: 3.99, image: "birthday.cake.fill"),
                MenuItem(name: "Tiramisu", price: 5.29, image: "birthday.cake.fill"),
                MenuItem(name: "Ice Cream", price: 3.79, image: "birthday.cake.fill")
            ]),
            
            SectionData(id: "sandwiches", name: "Sandwiches", items: [
                MenuItem(name: "Club Sandwich", price: 5.99, image: "takeoutbag.and.cup.and.straw.fill"),
                MenuItem(name: "Chicken Panini", price: 6.29, image: "takeoutbag.and.cup.and.straw.fill"),
                MenuItem(name: "Ham & Cheese", price: 5.49, image: "takeoutbag.and.cup.and.straw.fill"),
                MenuItem(name: "Egg Mayo", price: 5.29, image: "takeoutbag.and.cup.and.straw.fill")
            ]),
            
            SectionData(id: "breakfast", name: "Breakfast", items: [
                MenuItem(name: "Pancakes", price: 4.99, image: "fork.knife"),
                MenuItem(name: "Waffles", price: 5.29, image: "fork.knife"),
                MenuItem(name: "French Toast", price: 4.79, image: "fork.knife"),
                MenuItem(name: "Avocado Toast", price: 5.49, image: "fork.knife")
            ]),
            
            SectionData(id: "specials", name: "Specials", items: [
                MenuItem(name: "House Blend Cold Brew", price: 5.99, image: "cup.and.saucer.fill"),
                MenuItem(name: "Signature Caramel Latte", price: 5.49, image: "cup.and.saucer.fill"),
                MenuItem(name: "Coconut Coffee Smoothie", price: 5.79, image: "cup.and.saucer.fill"),
                MenuItem(name: "Iced Matcha Espresso Fusion", price: 5.69, image: "cup.and.saucer.fill")
            ]),
            
            SectionData(id: "non_coffee", name: "Non-Coffee Drinks", items: [
                MenuItem(name: "Hot Chocolate", price: 3.99, image: "cup.and.saucer.fill"),
                MenuItem(name: "Milk Tea", price: 3.79, image: "cup.and.saucer.fill"),
                MenuItem(name: "Iced Lemonade", price: 3.59, image: "cup.and.saucer.fill"),
                MenuItem(name: "Honey Lemon", price: 3.49, image: "cup.and.saucer.fill")
            ])
        ]
    
    @State private var selectedSectionID: String? = nil
    @State private var visibleSectionID: String? = nil
    @State private var isProgrammaticScroll = false
    
    var body: some View {
        HStack(spacing: 0) {
            // LEFT SECTION MENU
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(sections) { section in
                            Button(action: {
                                isProgrammaticScroll = true
                                withAnimation(.easeInOut) {
                                    selectedSectionID = section.id
                                }
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
                                    
                                    // Persistent accent line on right edge
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
            
            // RIGHT SIDE - ITEMS
            ScrollViewReader { contentProxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(sections) { section in
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
                    if !isProgrammaticScroll {
                        updateVisibleSection(values: values)
                    }
                }
                .onChange(of: selectedSectionID) { newValue in
                    if let id = newValue, isProgrammaticScroll {
                        withAnimation(.easeInOut) {
                            contentProxy.scrollTo(id, anchor: .top)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            isProgrammaticScroll = false
                        }
                    }
                }
            }
        }
        .onChange(of: visibleSectionID) { newValue in
            selectedSectionID = newValue
        }
    }
    
    private func updateVisibleSection(values: [String: CGFloat]) {
        let sorted = values.sorted { $0.value < $1.value }
        if let topSection = sorted.first?.key {
            visibleSectionID = topSection
        }
    }
}

// MARK: - Menu Item Row
struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 16) {
            // LEFT SIDE (Text Info)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(String(format: "$%.2f", item.price))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // RIGHT SIDE (Image)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    Image(systemName: item.image)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .padding(12)
                )
                .frame(width: 80, height: 80)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Models
struct SectionData: Identifiable {
    var id: String
    var name: String
    var items: [MenuItem]
}

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let image: String
}

// MARK: - Preference Key
struct SectionOffsetKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

#Preview {
    DualScrollView()
}

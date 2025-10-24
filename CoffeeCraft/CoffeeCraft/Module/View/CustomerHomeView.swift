//
//  CustomerHomeView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct CustomerHomeView: View {
    @StateObject private var productVM = ProductViewModel()
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedSectionID: String? = nil
    @State private var visibleSectionID: String? = nil
    @State private var isProgrammaticScroll = false
    
    @State private var showCartSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Main Split View (Left Category + Right Product List)
            HStack(spacing: 0) {
                // MARK: Left Category Menu
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
                                                .foregroundColor(selectedSectionID == section.id ? .brown : .primary)
                                                .padding(.vertical, 10)
                                                .padding(.leading, 8)
                                            Spacer()
                                        }
                                        
                                        Rectangle()
                                            .fill(selectedSectionID == section.id ? Color.brown : Color.clear)
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
                
                // MARK: Right Product List
                ScrollViewReader { contentProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            ForEach(productVM.sections) { section in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(section.name)
                                        .font(.title3.bold())
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    
                                    VStack(spacing: 10) {
                                        ForEach(section.items) { product in
                                            NavigationLink(value: product) {
                                                MenuItemRow(item: product)
                                                    .id("\(section.id)_\(product.name)")
                                            }
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
                        .padding(.bottom, 100) // leave space for cart bar
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
            
            // MARK: - Sticky "View Cart" Button
            if !cartManager.items.isEmpty {
                ViewCartButton(cartManager: cartManager) {
                    showCartSheet = true
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: cartManager.items.count)
            }
        }
        .onChange(of: visibleSectionID) { newValue in
            selectedSectionID = newValue
        }
        .navigationDestination(for: Product.self) { product in
            CoffeeDetailView(product: product)
                .environmentObject(cartManager)
        }
        .task {
            await productVM.fetchProducts()
            selectedSectionID = productVM.sections.first?.id
        }
        .fullScreenCover(isPresented: $showCartSheet) {
            CartView()
                .environmentObject(cartManager)
                .presentationDetents([.large]) // draggable up
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

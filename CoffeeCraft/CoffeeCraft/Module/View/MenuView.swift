//
//  MenuView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MenuView: View {
    @StateObject private var productVM = ProductViewModel()
    @EnvironmentObject var cartManager: CartManager

    @State private var selectedSectionID: String? = nil
    @State private var visibleSectionID: String? = nil
    @State private var isProgrammaticScroll = false

    @State private var showCartSheet = false
    @State private var showEditSheet = false
    @State private var productToEdit: Product?

    var isManager: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                categorySidebar
                Divider()
                productList
            }

            if !cartManager.items.isEmpty && !isManager {
                ViewCartButton(cartManager: cartManager) {
                    showCartSheet = true
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: cartManager.items.count)
            }
        }
        .onAppear {
            productVM.listenProducts()
        }
        .onChange(of: visibleSectionID) { newValue in
            selectedSectionID = newValue
        }
        .navigationDestination(for: Product.self) { product in
            CoffeeDetailView(product: product)
                .environmentObject(cartManager)
        }
        .fullScreenCover(isPresented: $showCartSheet) {
            CartView()
                .environmentObject(cartManager)
        }
        .sheet(isPresented: $showEditSheet) {
            if let productToEdit = productToEdit {
                // Find the product in ViewModel array to bind
                if let index = productVM.products.firstIndex(of: productToEdit) {
                    EditProductView(productVM: productVM, product: $productVM.products[index])
                } else {
                    // For new product not in array yet
                    EditProductView(productVM: productVM, product: .constant(productToEdit))
                }
            }
        }
    }

    // MARK: - Sidebar
    private var categorySidebar: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(productVM.sections) { section in
                        Button {
                            isProgrammaticScroll = true
                            withAnimation { selectedSectionID = section.id }
                        } label: {
                            HStack {
                                Text(section.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(selectedSectionID == section.id ? .brown : .primary)
                                    .padding(.vertical, 10)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                            .background(
                                Rectangle()
                                    .fill(selectedSectionID == section.id ? Color.brown.opacity(0.15) : Color.clear)
                            )
                            .cornerRadius(6)
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
    }

    // MARK: - Product List
    private var productList: some View {
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
                                            .id("\(section.id)_\(product.id)")
                                            .contextMenu(isManager ? ContextMenu(menuItems: {
                                                Button("Edit", systemImage: "pencil") {
                                                    productToEdit = product
                                                    showEditSheet = true
                                                }
                                                Button("Remove", role: .destructive) {
                                                    Task {
                                                        await productVM.deleteProduct(product)
                                                    }
                                                }
                                                Button("Mark as Unavailable", systemImage: "nosign") {
                                                    Task {
                                                        await productVM.markUnavailable(product)
                                                    }
                                                }
                                            }) : nil)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                if isManager {
                                                    Button("Edit") {
                                                        productToEdit = product
                                                        showEditSheet = true
                                                    }.tint(.blue)

                                                    Button("Unavailable") {
                                                        Task {
                                                            await productVM.markUnavailable(product)
                                                        }
                                                    }.tint(.orange)

                                                    Button(role: .destructive) {
                                                        Task {
                                                            await productVM.deleteProduct(product)
                                                        }
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                            }
                                    }
                                }

                                if isManager {
                                    Button(action: {
                                        productToEdit = Product.empty(in: section.id)
                                        showEditSheet = true
                                    }) {
                                        Label("Add new item", systemImage: "plus.circle.fill")
                                            .font(.subheadline)
                                            .foregroundColor(.brown)
                                    }
                                    .padding(.vertical, 6)
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
                .padding(.bottom, 100)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(SectionOffsetKey.self) { values in
                if !isProgrammaticScroll { updateVisibleSection(values: values) }
            }
            .onChange(of: selectedSectionID) { newValue in
                if let id = newValue, isProgrammaticScroll {
                    withAnimation { contentProxy.scrollTo(id, anchor: .top) }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { isProgrammaticScroll = false }
                }
            }
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

struct EditProductView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var productVM: ProductViewModel
    @Binding var product: Product   // <-- Binding to source of truth

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $product.name)
                TextField("Description", text: $product.description)
                TextField("Price", value: $product.price, format: .number)
                TextField("Image URL", text: $product.imageURL)
                Toggle("Available", isOn: $product.available)
            }
            .navigationTitle(productVM.products.contains(product) ? "Edit Product" : "Add Product")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await productVM.saveProduct(product)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}


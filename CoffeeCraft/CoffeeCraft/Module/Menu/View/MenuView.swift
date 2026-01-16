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
    @EnvironmentObject var favVM: FavoriteViewModel
    @State private var selectedSectionID: String? = nil
    @State private var visibleSectionID: String? = nil
    @State private var isProgrammaticScroll = false

    @State private var showCartSheet = false
    @State private var selectedProductToEdit: Product?

    var isManager: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                categorySidebar
                Divider()
                productList
            }

            if !cartManager.items.isEmpty {
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
        .onChange(of: visibleSectionID) { newValue, _ in
            selectedSectionID = newValue
        }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
                .environmentObject(cartManager)
                .environmentObject(favVM)
        }
        .navigationDestination(item: $selectedProductToEdit) { product in
            if let index = productVM.products.firstIndex(where: { $0.id == product.id }) {
                EditProductView(productVM: productVM,
                                productID: productVM.products[index].id,
                                productName: productVM.products[index].name,
                                productDescription: productVM.products[index].description,
                                productPrice: productVM.products[index].price,
                                productCategory: productVM.products[index].category,
                                productImageURL: productVM.products[index].imageURL,
                                productAvailable: productVM.products[index].available)
            } else {
                EditProductView(productVM: productVM,
                                productID: "",
                                productName: "",
                                productDescription: "",
                                productPrice: 0.0,
                                productCategory: selectedSectionID ?? "",
                                productImageURL: "",
                                productAvailable: true,
                               isEditing: false)
            }
        }

        .fullScreenCover(isPresented: $showCartSheet) {
            CartView()
                .environmentObject(cartManager)
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
                                                    selectedProductToEdit = product
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
                                    }
                                }

                                if isManager {
                                    Button(action: {
                                        selectedSectionID = section.id
                                        selectedProductToEdit = Product.empty(in: section.id)
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
            .onChange(of: selectedSectionID) { newValue, _ in
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

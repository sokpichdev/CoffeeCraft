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

    // MARK: - ViewModels
    @StateObject private var productVM = ProductViewModel()
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var favVM: FavoriteViewModel

    // MARK: - Scroll Sync State
    @State private var selectedSectionID: String?
    @State private var productScrollProxy: ScrollViewProxy?
    @State private var isScrollingProgrammatically = false
    @State private var scrollDebounceTask: Task<Void, Never>?

    // MARK: - UI State
    @State private var showCartSheet = false
    @State private var selectedProductToEdit: Product?
    @State private var showSearchSheet = false

    var isManager: Bool = false

    // MARK: - Body
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
            if let userId = UserSession.shared.userId {
                cartManager.loadCartFromFirestore(userId: userId)
            }
            // Set initial section
            if selectedSectionID == nil, let firstSection = productVM.sections.first {
                selectedSectionID = firstSection.id
            }
        }
        .customNavigationBar("Menu") {
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("magnifyingglass")) {
                showSearchSheet = true
            }
        }
        .fullScreenCover(isPresented: $showCartSheet) {
            CartView()
                .environmentObject(cartManager)
                .environmentObject(favVM)
        }
        .sheet(isPresented: $showSearchSheet) {
            SearchView(products: productVM.products)
                .environmentObject(cartManager)
                .environmentObject(favVM)
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
                                productAvailable: productVM.products[index].available,
                                productCustomizations: productVM.products[index].customizations ?? [:])
            } else {
                EditProductView(productVM: productVM,
                                productID: "",
                                productName: "",
                                productDescription: "",
                                productPrice: 0.0,
                                productCategory: selectedSectionID ?? "",
                                productImageURL: "",
                                productAvailable: true,
                                productCustomizations: [:],
                                isEditing: false)
            }
        }
    }

    // MARK: - Sidebar
    private var categorySidebar: some View {
        ScrollViewReader { sidebarProxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(productVM.sections) { section in
                        Button {
                            scrollToSection(section.id)
                        } label: {
                            HStack {
                                Text(section.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(
                                        selectedSectionID == section.id ? .brown : .primary
                                    )
                                    .padding(.vertical, 10)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                            .background(
                                Rectangle()
                                    .fill(
                                        selectedSectionID == section.id
                                        ? Color.brown.opacity(0.15)
                                        : Color.clear
                                    )
                            )
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .id("sidebar_\(section.id)")
                    }
                }
                .padding(.leading, 5)
                .padding(.vertical, 10)
            }
            .frame(width: 120)
            .background(Color(.systemGray6))
            .onChange(of: selectedSectionID) { _, newSection in
                // Auto-scroll sidebar to keep selected category visible
                if let newSection = newSection, !isScrollingProgrammatically {
                    withAnimation {
                        sidebarProxy.scrollTo("sidebar_\(newSection)", anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Product List
    private var productList: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(productVM.sections) { section in
                        sectionView(section)
                            .id(section.id)
                    }
                }
                .padding(.bottom, 100)
            }
            .onAppear {
                productScrollProxy = proxy
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(SectionOffsetKey.self) { values in
                // Only update from user scrolling
                guard !isScrollingProgrammatically else { return }
                updateVisibleSection(values: values)
            }
        }
    }

    // MARK: - Section View
    private func sectionView(_ section: SectionData) -> some View {
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
                    Button {
                        selectedSectionID = section.id
                        selectedProductToEdit = Product.empty(in: section.id)
                    } label: {
                        Label("Add new item", systemImage: "plus.circle.fill")
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
    }

    // MARK: - Scroll Helpers
    private func scrollToSection(_ id: String) {
        guard let proxy = productScrollProxy else { return }

        // Cancel any pending debounce task
        scrollDebounceTask?.cancel()
        
        // Set programmatic scrolling flag
        isScrollingProgrammatically = true
        selectedSectionID = id

        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(id, anchor: .top)
        }

        // Reset flag after animation completes with some buffer
        scrollDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            if !Task.isCancelled {
                isScrollingProgrammatically = false
            }
        }
    }

    private func updateVisibleSection(values: [String: CGFloat]) {
        // Cancel previous debounce
        scrollDebounceTask?.cancel()
        
        // Debounce the update to avoid jitter
        scrollDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            
            if Task.isCancelled { return }
            
            // Find the section closest to the top with a threshold
            let threshold: CGFloat = 100 // Adjust this value as needed
            
            let visibleSections = values.filter { $0.value >= -threshold && $0.value <= threshold }
            
            if let closestSection = visibleSections.min(by: { abs($0.value) < abs($1.value) }) {
                if selectedSectionID != closestSection.key {
                    selectedSectionID = closestSection.key
                }
            } else if let topSection = values.filter({ $0.value <= 0 }).max(by: { $0.value < $1.value }) {
                // If no section is near top, use the one that just scrolled past
                if selectedSectionID != topSection.key {
                    selectedSectionID = topSection.key
                }
            }
        }
    }
}

import FirebaseAuth
import FirebaseFirestore
//
//  MenuView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import SwiftUI

struct MenuView: View {
    
    // MARK: - ViewModels
    @EnvironmentObject var productVM: ProductViewModel
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var cardVM: CardViewModel
    @EnvironmentObject var favVM: FavoriteViewModel
    @EnvironmentObject var orderEnv: OrderEnvironment
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showAuth = false
    
    private struct EditTarget: Identifiable, Hashable {
        var id: String { product.id + sectionId }
        let sectionId: String
        let product: Product
    }
    @State private var editTarget: EditTarget?
    
    // MARK: - Scroll Sync State
    @State private var selectedSectionID: String?
    @State private var productScrollProxy: ScrollViewProxy?
    @State private var isScrollingProgrammatically = false
    @State private var programmaticResetTask: Task<Void, Never>?
    // MARK: - UI State
    @State private var showCartSheet = false
    @State private var selectedProductToEdit: Product?
    @State private var showSearchSheet = false
    @State private var showBranchSheet      = false
    @State private var pendingFulfillmentBranch: Branch?
    
    var isManager: Bool = false
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            if orderEnv.selectedBranch == nil {
                // ── No branch selected — show placeholder ──────────────
                noBranchSelectedView
            } else {
                // ── Branch selected — show menu ────────────────────────
                HStack(spacing: 0) {
                    categorySidebar
                    Rectangle()
                        .fill(Color.borderColor)
                        .frame(width: 0.5)
                        .frame(maxHeight: .infinity)
                        .ignoresSafeArea(edges: .top)
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
        }
        .onAppear {
            productVM.listenProducts()
            if let userId = UserSession.shared.userId {
                cartManager.loadCartFromFirestore(userId: userId)
            }
            if selectedSectionID == nil, let firstSection = productVM.sections.first {
                selectedSectionID = firstSection.id
            }
            // Auto-present branch sheet if no branch is selected yet
            if orderEnv.selectedBranch == nil && orderEnv.pendingMapBranch == nil {
                showBranchSheet = true
            }
            // Note: map shortcut (pendingMapBranch) is handled by onChange below.
            // onAppear only runs once on first render — onChange catches subsequent changes.
        }
        // Map shortcut: pendingMapBranch is set in MenuBranchSelectionSheet 0.6s after
        // dismiss(), so showBranchSheet is already false when this fires.
        .onChange(of: orderEnv.pendingMapBranch) { _, mapBranch in
            guard let branch = mapBranch else { return }
            pendingFulfillmentBranch = branch
        }
        .customNavigationBar("") {
            ToolBarButton(placement: .topBarTrailing, buttonType: .icon("magnifyingglass")) {
                if UserSession.shared.isLoggedIn {
                    showSearchSheet = true
                } else {
                    showAuth = true
                }
            }
            if let branchName = orderEnv.selectedBranchName {
                ToolBarButton(placement: .topBarLeading, buttonType: .text(branchName), action: {
                    showBranchSheet = true
                })
            }
        }
        .fullScreenCover(isPresented: $showCartSheet) {
            CartView()
                .environmentObject(cartManager)
                .environmentObject(favVM)
                .environmentObject(cardVM)
                .environmentObject(OrderEnvironment.shared)
        }
        .sheet(isPresented: $showSearchSheet) {
            SearchView(products: productVM.products)
                .environmentObject(cartManager)
                .environmentObject(favVM)
        }
        .sheet(isPresented: $showBranchSheet) {
            MenuBranchSelectionSheet(onBranchSelected: { branch in
                // Capture branch before the sheet dismisses — @State on a dismissing
                // view goes stale. Set pendingFulfillmentBranch after the dismiss
                // animation so sheet(item:) doesn't fire while showBranchSheet is still true.
                let capturedBranch = branch
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    pendingFulfillmentBranch = capturedBranch
                }
            })
            .environmentObject(orderEnv)
        }
        // Use item: instead of isPresented: so the branch is guaranteed non-nil
        // when the sheet content renders. With isPresented: there is a race where
        // onDismiss sets pendingFulfillmentBranch = nil before the next presentation's
        // content closure evaluates, producing a blank sheet.
        .sheet(item: $pendingFulfillmentBranch) { branch in
            FulfillmentPickerSheet(branch: branch)
                .environmentObject(orderEnv)
        }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product, allProducts: productVM.products)
                .environmentObject(cartManager)
                .environmentObject(favVM)
        }
        .navigationDestination(isPresented: $showAuth) {
            AuthView().environmentObject(authVM)
        }
        .navigationDestination(item: $editTarget) { target in
            handleNavigateToEditProduct(sectionId: target.sectionId, product: target.product)
        }
    }
    
    // MARK: - Branch Nav Title helper
    // Returns the tappable branch name or a plain "Menu" title.
    // Tapping the branch name re-opens the branch sheet.
    private var branchNavTitle: String {
        orderEnv.selectedBranchName ?? "Menu"
    }
    
    // MARK: - Section View
    private func sectionView(_ section: SectionData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(section.items) { product in
                NavigationLink(value: product) {
                    MenuItemRow(item: product)
                        .id("\(section.id)_\(product.id)")
                        .contextMenu(isManager ? ContextMenu(menuItems: {
                            Button("Edit", systemImage: "pencil") {
                                editTarget = EditTarget(sectionId: section.id, product: product)
                            }
                            Button("Remove", role: .destructive) {
                                Task { await productVM.deleteProduct(product) }
                            }
                            Button("Mark as Unavailable", systemImage: "nosign") {
                                Task { await productVM.markUnavailable(product) }
                            }
                        }) : nil)
                }
                .buttonStyle(.plain)
            }
            
            if isManager {
                NavigationLink {
                    handleNavigateToEditProduct(sectionId: section.id, product: Product.empty(in: section.id))
                } label: {
                    Label("Add new item", systemImage: "plus.circle.fill")
                        .foregroundColor(.accentPrimary)
                }
                .padding(.vertical, 6)
            }
        }
        .padding(12)
        .background(Color.bgPrimary)
        .clipShape(
            .rect(topLeadingRadius: 0, bottomLeadingRadius: 12,
                  bottomTrailingRadius: 12, topTrailingRadius: 0)
        )
        .overlay(
            UnevenRoundedRectangle(
                topLeadingRadius: 0, bottomLeadingRadius: 12,
                bottomTrailingRadius: 12, topTrailingRadius: 0
            )
            .strokeBorder(Color.borderColor, lineWidth: 0.5)
        )
        .padding(.horizontal, 12)
    }
}

struct MenuSectionShimmerView: View {
    let itemCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShimmerView(cornerRadius: 6)
                .frame(width: 120, height: 23)
                .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(0..<itemCount, id: \.self) { _ in
                    menuItemRowShimmer
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var menuItemRowShimmer: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                ShimmerView(cornerRadius: 4)
                    .frame(width: 130, height: 17)
                ShimmerView(cornerRadius: 4)
                    .frame(width: 55, height: 14)
            }
            Spacer()
            ShimmerView(cornerRadius: 10)
                .frame(width: 60, height: 60)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.surfaceSub.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.surfaceSub.opacity(0.4), radius: 1)
    }
}

extension MenuView {
    // MARK: - Scroll Helpers
    private func scrollToSection(_ id: String) {
        guard let proxy = productScrollProxy else { return }

        programmaticResetTask?.cancel() // cancel any previous reset

        isScrollingProgrammatically = true
        selectedSectionID = id

        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            proxy.scrollTo(id, anchor: .top)
        }

        // Separate task — never cancelled by scroll events
        programmaticResetTask = Task {
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
            if !Task.isCancelled {
                isScrollingProgrammatically = false
            }
        }
    }
    private func updateVisibleSection(values: [String: CGFloat]) {
        Task {
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms — smooth but not sluggish
            if Task.isCancelled { return }
            
            // Wider threshold to avoid flickering at section boundaries
            let threshold: CGFloat = 10  // roughly one header height
            
            if let topSection = values
                .filter({ $0.value <= threshold }) // sections that have reached the top
                .max(by: { $0.value < $1.value }) { // the one closest to top without passing it
                if selectedSectionID != topSection.key {
                    await MainActor.run {
                        selectedSectionID = topSection.key
                    }
                }
            }
        }
    }
}

extension MenuView {
    // MARK: - No Branch Selected View
    private var noBranchSelectedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "mappin.circle")
                .font(.system(size: 56))
                .foregroundColor(.textMuted)

            VStack(spacing: 8) {
                Text("Please select a store")
                    .font(.custom("Nunito-Bold", size: 20))
                    .foregroundColor(.textPrimary)
                Text("Choose a branch to see its menu and place an order.")
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                showBranchSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Select a Store")
                        .font(.custom("Nunito-Bold", size: 16))
                }
                .foregroundColor(.white)
                .frame(height: 50)
                .padding(.horizontal, 32)
                .background(Color.accentPrimary)
                .cornerRadius(14)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary)
    }
//    @ViewBuilder
    private func handleNavigateToEditProduct(sectionId: String, product: Product) -> some View {
        if let index = productVM.products.firstIndex(where: { $0.id == product.id }) {
            return EditProductView(productVM: productVM,
                            productID: productVM.products[index].id,
                            productName: productVM.products[index].name,
                            productDescription: productVM.products[index].description,
                            productPrice: productVM.products[index].price,
                            productCategory: productVM.products[index].category,
                            productImageURL: productVM.products[index].imageURL,
                            productAvailable: productVM.products[index].available,
                            productCustomizations: productVM.products[index].customizations ?? [:])
        } else {
            return EditProductView(productVM: productVM,
                            productID: "",
                            productName: "",
                            productDescription: "",
                            productPrice: 0.0,
                            productCategory: sectionId,
                            productImageURL: "",
                            productAvailable: true,
                            productCustomizations: [:],
                            isEditing: false)
        }
    }
    // MARK: - Sidebar
    private var categorySidebar: some View {
        ScrollViewReader { sidebarProxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    if productVM.isLoading {
                        ForEach(0..<6, id: \.self) { _ in
                            ShimmerView(cornerRadius: 10)
                                .frame(height: 41)
                        }
                    } else {
                        ForEach(productVM.sections) { section in
                            Button {
                                scrollToSection(section.id)
                            } label: {
                                HStack {
                                    Text(section.name)
                                        .font(.subheadline).fontWeight(.medium)
                                        .foregroundColor(
                                            selectedSectionID == section.id ? .accentGold : .textPrimary
                                        )
                                        .padding(.vertical, 10)
                                        .padding(.leading, 8)
                                    Spacer()
                                }
                                .frame(minHeight: 40)
                                .background(
                                    Rectangle()
                                        .fill(
                                            selectedSectionID == section.id
                                            ? Color.accentPrimary.opacity(0.15)
                                            : Color.clear
                                        )
                                )
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            .id("sidebar_\(section.id)")
                        }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 10)
            }
            .frame(width: 120)
            .background(Color.bgSecondary)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if let current = selectedSectionID {
                        sidebarProxy.scrollTo("sidebar_\(current)", anchor: .center)
                    }
                }
            }
            .onChange(of: selectedSectionID) { _, newSection in
                if let newSection, !isScrollingProgrammatically {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        sidebarProxy.scrollTo("sidebar_\(newSection)", anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Product List
    private var productList: some View {
        ScrollViewReader { proxy in
            if productVM.isLoading {
                CustomRefreshScrollView( {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach([4, 3, 5], id: \.self) { itemCount in
                           MenuSectionShimmerView(itemCount: itemCount)
                        }
                    }
                    .padding(.bottom, 70)
                })
                .transition(.opacity)
            } else {
                CustomRefreshScrollView({
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(productVM.sections) { section in
                            Section {
                                sectionView(section)
                                    .id(section.id)
                                    .padding(.bottom)
                            } header: {
                                sectionHeader(section)
                            }
                        }
                    }
                    .padding(.bottom, 70)
                }, onRefresh: {
                    await productVM.refreshProducts()
                })
                .onAppear {
                    productScrollProxy = proxy
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(SectionOffsetKey.self) { values in
                    guard !isScrollingProgrammatically else { return }
                    updateVisibleSection(values: values)
                }
                .transition(.opacity)
            }
        }
        .clipped()
        .background(Color.bgPrimary.opacity(0.8))
    }

    private func sectionHeader(_ section: SectionData) -> some View {
        Text(section.name)
            .font(.title3.bold())
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color.bgPrimary)
            .clipShape(
                .rect(topLeadingRadius: 12, bottomLeadingRadius: 0,
                      bottomTrailingRadius: 0, topTrailingRadius: 12)
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0, topTrailingRadius: 12
                )
                .strokeBorder(Color.borderColor, lineWidth: 0.5)
            )
            .background(Color.bgPrimary.opacity(0.8))
            .padding(.horizontal, 12)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: SectionOffsetKey.self,
                        value: [section.id: geo.frame(in: .named("scroll")).minY]
                    )
                }
            )
    }
}

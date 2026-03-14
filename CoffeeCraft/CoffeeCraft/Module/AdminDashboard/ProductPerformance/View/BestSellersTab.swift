//
//  BestSellersTab.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

// MARK: - Best Sellers Tab

/// LazyVStack means rows are only instantiated as they scroll into view.
/// For very long lists this is the single biggest win.
struct BestSellersTab: View {
    @ObservedObject var vm: ProductPerformanceViewModel

    var body: some View {
        CustomRefreshScrollView({
            if vm.isLoading {
                DashboardLoadingPlaceholder(count: 5)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
            } else if !vm.hasData {
                DashboardEmptyState(
                    icon: "trophy",
                    title: "No sales data yet",
                    message: "Complete some orders to see product performance."
                )
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
            } else {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        let products = vm.performanceData?.topProducts ?? []
                        ForEach(Array(products.enumerated()), id: \.element.id) { index, item in
                            BestSellerRow(item: item, maxUnits: vm.maxUnitsSold)
                                .id(item.id)

                            if index < products.count - 1 {
                                Divider()
                                    .padding(.leading, 28)
                                    .background(Color.borderColor)
                            }
                        }
                    } header: {
                        listHeader
                    }
                }
                .background(Color.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16))
            }
        }, onRefresh: {
            await vm.loadPerformance()
        })
    }

    private var listHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text("#").frame(width: 22, alignment: .center)
                Text("Product").frame(maxWidth: .infinity, alignment: .leading)
                Text("Sold").frame(width: 44, alignment: .trailing)
                Text("Revenue").frame(width: 72, alignment: .trailing)
                Text("★").frame(width: 34, alignment: .trailing)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.textMuted)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider().background(Color.borderColor)
        }
        // Opaque background is required — without it, rows scroll
        // visibly behind the header as they pass underneath it.
        .background(Color.surfacePrimary)
    }
}

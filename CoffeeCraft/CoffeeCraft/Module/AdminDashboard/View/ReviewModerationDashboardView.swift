//
//  ReviewModerationDashboardView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/13/26.
//

import Charts
import SwiftUI

// MARK: - Review Moderation Dashboard View

struct ReviewModerationDashboardView: View {

    @StateObject private var vm = ReviewModerationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showProductSheet = false
    var body: some View {
        VStack(spacing: 0) {
            sectionPicker
            content
        }
        .sheet(isPresented: $showProductSheet) {
            ProductPickerSheet(
                options: vm.productOptions,
                selectedId: $vm.selectedProductId,
                onSelect: { Task { await vm.productChanged() } }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .customNavigationBar("Review Moderation") {
            ToolBarButton.back {
                dismiss()
            }
        }
        .onAppear { vm.onAppear() }
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        Picker("Section", selection: $vm.selectedSection) {
            ForEach(ReviewDashboardSection.allCases) { section in
                Label(section.rawValue, systemImage: section.icon).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.bgSecondary)
    }

    // MARK: - Content Router

    @ViewBuilder
    private var content: some View {
        switch vm.selectedSection {
        case .queue: queueSection
        case .analytics: analyticsSection
        }
    }

    // MARK: - REVIEW QUEUE ─

    private var queueSection: some View {
        VStack(spacing: 0) {
            filterBar
            Divider().background(Color.borderColor)
            reviewList
        }
    }

    private var filterBar: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ReviewVisibility.allCases) { vis in
                        FilterChip(label: vis.rawValue,
                                   isSelected: vm.filter.visibility == vis,
                                   color: .accentPrimary) {
                            vm.filter.visibility = vis
                            Task { await vm.applyFilter() }
                        }
                    }

                    Divider().frame(height: 20).background(Color.borderColor)

                    ForEach([1, 2, 3, 4, 5], id: \.self) { stars in
                        FilterChip(label: "\(stars)★",
                                   isSelected: vm.filter.rating == stars,
                                   color: .accentGold) {
                            vm.filter.rating = (vm.filter.rating == stars) ? nil : stars
                            Task { await vm.applyFilter() }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            if !vm.productOptions.isEmpty {
                HStack {
                    Text("Product:")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                    Button {
                        showProductSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(vm.productOptions.first(where: { $0.id == vm.filter.productId })?.name ?? "All Products")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentPrimary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color.accentPrimary.opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentPrimary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentPrimary.opacity(0.20), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    if !vm.filter.isEmpty {
                        Button("Clear") {
                            vm.filter = ReviewFilter()
                            Task { await vm.applyFilter() }
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentPrimary)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 10)
        .background(Color.bgSecondary)
    }

    @ViewBuilder
    private var reviewList: some View {
        CustomRefreshScrollView({
            if vm.isLoadingQueue {
                reviewListSkeleton
            } else if vm.reviews.isEmpty {
                DashboardEmptyState(
                    icon: "bubble.left.and.bubble.right",
                    title: "No reviews found",
                    message: vm.filter.isEmpty
                    ? "No reviews have been submitted yet."
                    : "Try adjusting your filters."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(vm.reviews) { review in
                        ReviewQueueCard(
                            review: review,
                            isToggling: vm.togglingIds.contains(review.id),
                            onToggle: { await vm.toggleHidden(for: review) }
                        )
                        .onAppear {
                            if review.id == vm.reviews.last?.id {
                                Task { await vm.loadMore() }
                            }
                        }
                    }
                    if vm.isLoadingMore {
                        ProgressView().tint(.accentPrimary).frame(maxWidth: .infinity).padding(.vertical, 16)
                    } else if !vm.canLoadMore && vm.reviews.count >= 30 {
                        Text("All reviews loaded")
                            .font(.caption).foregroundStyle(Color.textMuted)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                    }
                }
                .padding(16)
            }
        }, onRefresh: {
            await vm.loadQueue()
        })
    }

    private var reviewListSkeleton: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<8, id: \.self) { _ in
                    ShimmerView()
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(16)
        }
    }

    // MARK: ─ ANALYTICS ─

    private var analyticsSection: some View {
        VStack(spacing: 0) {
            productPickerBar
            Divider().background(Color.borderColor)

            CustomRefreshScrollView({
                if vm.isLoadingAnalytics {
                    DashboardLoadingPlaceholder(count: 3).padding(16)
                } else if let data = vm.analyticsData {
                    VStack(spacing: 20) {
                        analyticsStatCards(data: data)
                        ratingDistributionChart(data: data)
                        if data.ratingOverTime.count >= 2 {
                            ratingOverTimeChart(data: data)
                        }
                    }
                    .padding()
                } else if vm.productOptions.isEmpty {
                    DashboardEmptyState(
                        icon: "star.slash",
                        title: "No products with reviews",
                        message: "Reviews will appear here once customers start rating products."
                    )
                }
            }, onRefresh: {
                await vm.loadAnalytics()
            })
        }
    }

    private func analyticsStatCards(data: ReviewAnalyticsData) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(title: "Avg Rating",
                         value: "\(data.avgRatingFormatted) ★",
                         icon: "star.fill",
                         color: .accentGold)
                StatCard(title: "Total Reviews",
                         value: "\(data.totalCount)",
                         icon: "bubble.left.fill",
                         color: .accentPrimary)
            }
            HStack(spacing: 12) {
                StatCard(title: "Visible",
                         value: "\(data.visibleCount)",
                         icon: "eye.fill", color: .semanticSuccess)
                StatCard(title: "Hidden",
                         value: "\(data.hiddenCount)",
                         icon: "eye.slash.fill",
                         color: data.hiddenCount > 0 ? .orange : .secondary)
            }
        }
    }

    private func ratingDistributionChart(data: ReviewAnalyticsData) -> some View {
        ChartCard(title: "Rating Distribution", subtitle: data.productName) {
            Chart(data.ratingDistribution) { bucket in
                BarMark(
                    x: .value("Stars", "\(bucket.stars)★"),
                    y: .value("Count", bucket.count)
                )
                .foregroundStyle(starColor(bucket.stars))
                .cornerRadius(6)
                .annotation(position: .top, alignment: .center) {
                    if bucket.count > 0 {
                        Text("\(bucket.count)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.textMuted)
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) { Text(label).font(.caption) }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    AxisValueLabel { value.as(Int.self).map { Text("\($0)").font(.caption2) } }
                }
            }
            .frame(height: 160)

            HStack {
                ForEach(data.ratingDistribution) { bucket in
                    Text(bucket.count > 0 ? String(format: "%.0f%%", bucket.percentage) : "")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 2)
        }
    }

    private func starColor(_ stars: Int) -> Color {
        switch stars {
        case 5: return .semanticSuccess
        case 4: return Color(red: 0.55, green: 0.82, blue: 0.28)
        case 3: return .accentGold
        case 2: return .orange
        default: return .semanticError
        }
    }
}

// MARK: - Review Queue Card

private struct ReviewQueueCard: View {
    let review: ReviewItem
    let isToggling: Bool
    let onToggle: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Product + customer header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.productName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentPrimary)
                    Text(review.customerName)
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
                Spacer()
                if review.isHidden {
                    Label("Hidden", systemImage: "eye.slash.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.10), in: Capsule())
                        .overlay(Capsule().stroke(Color.orange.opacity(0.25), lineWidth: 1))
                }
            }

            // Stars + date
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { idx in
                        Image(systemName: idx <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundStyle(idx <= review.rating ? Color.accentGold : Color.borderColor)
                    }
                }
                Text("·").foregroundStyle(Color.borderColor)
                Text(review.timestampFormatted)
                    .font(.caption2)
                    .foregroundStyle(Color.textMuted)
            }

            // Review body
            Text(review.excerpt)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Divider().background(Color.borderColor)

            // Action
            HStack {
                Spacer()
                Button {
                    Task { await onToggle() }
                } label: {
                    if isToggling {
                        ProgressView().scaleEffect(0.8).frame(width: 80, height: 28)
                    } else {
                        Label(
                            review.isHidden ? "Unhide" : "Hide",
                            systemImage: review.isHidden ? "eye.fill" : "eye.slash.fill"
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(review.isHidden ? Color.semanticSuccess : .orange)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            (review.isHidden ? Color.semanticSuccess : Color.orange).opacity(0.10),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().stroke(
                                (review.isHidden ? Color.semanticSuccess : Color.orange).opacity(0.25),
                                lineWidth: 1
                            )
                        )
                    }
                }
                .buttonStyle(.plain)
                .disabled(isToggling)
            }
        }
        .padding(16)
        .background(
            review.isHidden ? Color.surfaceSub : Color.surfacePrimary,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(review.isHidden ? Color.orange.opacity(0.22) : Color.borderColor, lineWidth: 1)
        )
        .opacity(review.isHidden ? 0.78 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: review.isHidden)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Filter Chip (local)

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.10), in: Capsule())
                .overlay(Capsule().stroke(color.opacity(isSelected ? 0 : 0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

extension ReviewModerationDashboardView {
    
    private var productPickerBar: some View {
        Button {
            showProductSheet = true
        } label: {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentPrimary.opacity(0.10))
                        .frame(width: 30, height: 30)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.accentPrimary)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Analysing product")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textMuted)
                    Text(vm.productOptions.first(where: { $0.id == vm.selectedProductId })?.name ?? "Select a product")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.accentPrimary.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
        .background(Color.bgSecondary)
        .overlay(alignment: .bottom) {
            Divider().background(Color.borderColor)
        }
    }
    
    private func ratingOverTimeChart(data: ReviewAnalyticsData) -> some View {
        ChartCard(title: "Rating Over Time", subtitle: "Weekly average · \(data.productName)") {
            Chart(data.ratingOverTime) { point in
                AreaMark(
                    x: .value("Week", point.weekStart, unit: .weekOfYear),
                    y: .value("Avg Rating", point.avgRating)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentGold.opacity(0.22), Color.accentGold.opacity(0.02)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Week", point.weekStart, unit: .weekOfYear),
                    y: .value("Avg Rating", point.avgRating)
                )
                .foregroundStyle(Color.accentGold)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Week", point.weekStart, unit: .weekOfYear),
                    y: .value("Avg Rating", point.avgRating)
                )
                .foregroundStyle(Color.accentGold)
                .symbolSize(30)
                .annotation(position: .top, spacing: 4) {
                    Text(String(format: "%.1f", point.avgRating))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .chartYScale(domain: 1...5.2)
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear, count: 2)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [1.0, 2.0, 3.0, 4.0, 5.0]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4))
                    AxisValueLabel {
                        if let value = value.as(Double.self) {
                            Text(String(format: "%.0f★", value)).font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }
}

// MARK: - Product Picker Sheet

private struct ProductPickerSheet: View {

    let options: [ProductOption]
    @Binding var selectedId: String?
    let onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // "All Products" row — only relevant in queue filter context
                // (analytics always needs a specific product, but harmless to include)
                Button {
                    selectedId = nil
                    onSelect()
                    dismiss()
                } label: {
                    HStack {
                        Label("All Products", systemImage: "square.stack.fill")
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        if selectedId == nil {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.accentPrimary)
                        }
                    }
                }
                .listRowBackground(Color.surfacePrimary)

                Section {
                    ForEach(options) { option in
                        Button {
                            selectedId = option.id
                            onSelect()
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                // Avatar initials circle
                                ZStack {
                                    Circle()
                                        .fill(Color.accentPrimary.opacity(0.10))
                                        .frame(width: 34, height: 34)
                                    Text(String(option.name.prefix(1)).uppercased())
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.accentPrimary)
                                }

                                Text(option.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                if selectedId == option.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.accentPrimary)
                                }
                            }
                        }
                        .listRowBackground(Color.surfacePrimary)
                    }
                } header: {
                    Text("Products")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                        .textCase(nil)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationTitle("Select Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentPrimary)
                }
            }
        }
    }
}

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

    var body: some View {
        VStack(spacing: 0) {
            sectionPicker
            content
        }
        .navigationTitle("Review Moderation")
        .navigationBarTitleDisplayMode(.large)
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
        .background(Color.bgPrimary)
    }

    // MARK: - Content Router

    @ViewBuilder
    private var content: some View {
        switch vm.selectedSection {
        case .queue:     queueSection
        case .analytics: analyticsSection
        }
    }

    // MARK: ─── SECTION: REVIEW QUEUE ─────────────────────────────────────────

    private var queueSection: some View {
        VStack(spacing: 0) {
            filterBar
            Divider()
            reviewList
        }
    }

    // MARK: Filter Bar

    private var filterBar: some View {
        VStack(spacing: 10) {
            // Visibility chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Visibility chips
                    ForEach(ReviewVisibility.allCases) { vis in
                        FilterChip(
                            label: vis.rawValue,
                            isSelected: vm.filter.visibility == vis,
                            color: .accentPrimary
                        ) {
                            vm.filter.visibility = vis
                            Task { await vm.applyFilter() }
                        }
                    }

                    Divider().frame(height: 20)

                    // Star rating chips
                    ForEach([1, 2, 3, 4, 5], id: \.self) { stars in
                        FilterChip(
                            label: "\(stars)★",
                            isSelected: vm.filter.rating == stars,
                            color: .yellow
                        ) {
                            vm.filter.rating = (vm.filter.rating == stars) ? nil : stars
                            Task { await vm.applyFilter() }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // Product picker (only shown when products exist)
            if !vm.productOptions.isEmpty {
                HStack {
                    Text("Product:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Picker("Product", selection: $vm.filter.productId) {
                        Text("All Products").tag(String?.none)
                        ForEach(vm.productOptions) { opt in
                            Text(opt.name).tag(String?.some(opt.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.caption)
                    .onChange(of: vm.filter.productId) { _, _ in
                        Task { await vm.applyFilter() }
                    }

                    Spacer()

                    // Active filter count badge
                    if !vm.filter.isEmpty {
                        Button("Clear") {
                            vm.filter = ReviewFilter()
                            Task { await vm.applyFilter() }
                        }
                        .font(.caption)
                        .foregroundStyle(Color.accentPrimary)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: Review List

    @ViewBuilder
    private var reviewList: some View {
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
            ScrollView {
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
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 16)
                    } else if !vm.canLoadMore && vm.reviews.count >= 30 {
                        Text("All reviews loaded")
                            .font(.caption).foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                    }
                }
                .padding(16)
            }
            .refreshable { await vm.loadQueue() }
        }
    }

    private var reviewListSkeleton: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<8, id: \.self) { _ in
                    ShimmerView()
                        .frame(maxWidth: .infinity, minHeight: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(16)
        }
    }

    // MARK: ─── SECTION: ANALYTICS ────────────────────────────────────────────

    private var analyticsSection: some View {
        VStack(spacing: 0) {
            productPickerBar
            Divider()

            if vm.isLoadingAnalytics {
                DashboardLoadingPlaceholder(count: 3)
                    .padding(16)
            } else if let data = vm.analyticsData {
                analyticsContent(data: data)
            } else if vm.productOptions.isEmpty {
                DashboardEmptyState(
                    icon: "star.slash",
                    title: "No products with reviews",
                    message: "Reviews will appear here once customers start rating products."
                )
            }
        }
    }

    private var productPickerBar: some View {
        HStack {
            Text("Product")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker("Product", selection: $vm.selectedProductId) {
                ForEach(vm.productOptions) { opt in
                    Text(opt.name).tag(String?.some(opt.id))
                }
            }
            .pickerStyle(.menu)
            .onChange(of: vm.selectedProductId) { _, _ in
                Task { await vm.productChanged() }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func analyticsContent(data: ReviewAnalyticsData) -> some View {
        CustomRefreshScrollView({
            VStack(spacing: 20) {
                analyticsStatCards(data: data)
                ratingDistributionChart(data: data)
                if data.ratingOverTime.count >= 2 {
                    ratingOverTimeChart(data: data)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }, onRefresh: {
            await vm.loadAnalytics()
        })
    }

    // MARK: Analytics Stat Cards

    private func analyticsStatCards(data: ReviewAnalyticsData) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Avg Rating",
                    value: "\(data.avgRatingFormatted) ★",
                    icon: "star.fill",
                    color: .yellow
                )
                StatCard(
                    title: "Total Reviews",
                    value: "\(data.totalCount)",
                    icon: "bubble.left.fill",
                    color: .blue
                )
            }
            HStack(spacing: 12) {
                StatCard(
                    title: "Visible",
                    value: "\(data.visibleCount)",
                    icon: "eye.fill",
                    color: .green
                )
                StatCard(
                    title: "Hidden",
                    value: "\(data.hiddenCount)",
                    icon: "eye.slash.fill",
                    color: data.hiddenCount > 0 ? .orange : .secondary
                )
            }
        }
    }

    // MARK: Rating Distribution Bar Chart

    private func ratingDistributionChart(data: ReviewAnalyticsData) -> some View {
        ChartCard(
            title: "Rating Distribution",
            subtitle: data.productName
        ) {
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
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label).font(.caption)
                        }
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

            // Percentage labels below bars
            HStack {
                ForEach(data.ratingDistribution) { bucket in
                    Text(bucket.count > 0 ? String(format: "%.0f%%", bucket.percentage) : "")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: Rating Over Time Line Chart

    private func ratingOverTimeChart(data: ReviewAnalyticsData) -> some View {
        ChartCard(
            title: "Rating Over Time",
            subtitle: "Weekly average · \(data.productName)"
        ) {
            Chart(data.ratingOverTime) { point in
                AreaMark(
                    x: .value("Week", point.weekStart, unit: .weekOfYear),
                    y: .value("Avg Rating", point.avgRating)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.25), Color.yellow.opacity(0.02)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Week", point.weekStart, unit: .weekOfYear),
                    y: .value("Avg Rating", point.avgRating)
                )
                .foregroundStyle(Color.yellow)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Week", point.weekStart, unit: .weekOfYear),
                    y: .value("Avg Rating", point.avgRating)
                )
                .foregroundStyle(Color.yellow)
                .symbolSize(30)
                .annotation(position: .top, spacing: 4) {
                    Text(String(format: "%.1f", point.avgRating))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
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
                        if let v = value.as(Double.self) {
                            Text(String(format: "%.0f★", v)).font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
    }

    // MARK: - Helpers

    private func starColor(_ stars: Int) -> Color {
        switch stars {
        case 5:    return .green
        case 4:    return Color(red: 0.6, green: 0.85, blue: 0.3)
        case 3:    return .yellow
        case 2:    return .orange
        default:   return .red
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

            // Top row: product name + hide button
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.productName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentPrimary)
                    Text(review.customerName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Hidden status badge
                if review.isHidden {
                    Label("Hidden", systemImage: "eye.slash.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                }
            }

            // Star rating + date
            HStack(spacing: 6) {
                // Individual star icons (more legible than the string approach)
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundStyle(i <= review.rating ? Color.yellow : Color.secondary.opacity(0.4))
                    }
                }
                Text("·")
                    .foregroundStyle(.tertiary)
                Text(review.timestampFormatted)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            // Review excerpt
            Text(review.excerpt)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            // Action button
            HStack {
                Spacer()
                Button {
                    Task { await onToggle() }
                } label: {
                    if isToggling {
                        ProgressView().scaleEffect(0.8)
                            .frame(width: 80, height: 28)
                    } else {
                        Label(
                            review.isHidden ? "Unhide" : "Hide",
                            systemImage: review.isHidden ? "eye.fill" : "eye.slash.fill"
                        )
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(review.isHidden ? .green : .orange)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            (review.isHidden ? Color.green : Color.orange).opacity(0.1),
                            in: Capsule()
                        )
                    }
                }
                .buttonStyle(.plain)
                .disabled(isToggling)
            }
        }
        .padding(14)
        .background(
            review.isHidden
                ? Color.surfaceSub
                : Color.surfacePrimary,
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    review.isHidden ? Color.orange.opacity(0.25) : Color.borderColor,
                    lineWidth: 1
                )
        )
        .opacity(review.isHidden ? 0.75 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: review.isHidden)
    }
}

// MARK: - Filter Chip (reused from 8.4, local copy avoids module-scope conflicts)

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
                .background(isSelected ? color : color.opacity(0.1), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

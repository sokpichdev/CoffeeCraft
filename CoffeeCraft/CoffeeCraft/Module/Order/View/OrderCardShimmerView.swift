//
//  OrderCardShimmerView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/24/26.
//
import SwiftUI

struct OrderCardShimmerView: View {
    var showAdminActions: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    ShimmerView(cornerRadius: 4)
                        .frame(width: 120, height: 12)
                    ShimmerView(cornerRadius: 4)
                        .frame(width: 60, height: 13)
                }
                Spacer()
                ShimmerView(cornerRadius: 12)
                    .frame(width: 80, height: 24)
            }

            Divider()

            // items
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<2, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            ShimmerView(cornerRadius: 4)
                                .frame(width: 120, height: 15)
                            Spacer()
                            ShimmerView(cornerRadius: 4)
                                .frame(width: 48, height: 15)
                        }
                        VStack(spacing: 2) {
                            ShimmerView(cornerRadius: 4)
                                .frame(width: 90, height: 12)
                            ShimmerView(cornerRadius: 4)
                                .frame(width: 90, height: 12)
                        }
                        Divider()
                    }
                }
            }

            // Footer total row
            HStack {
                ShimmerView()
                    .frame(width: 40, height: 15)
                Spacer()
                ShimmerView()
                    .frame(width: 56, height: 15)
            }
            .padding(.top, 4)

            // Admin action buttons placeholder
            if showAdminActions {
                Divider()
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        ShimmerView()
                            .frame(width: CGFloat(65 + (10 * i)), height: 40)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
        .shadow(color: Color.primary.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct OrderListShimmerView: View {
    var showAdminActions: Bool = false
    var count: Int = 3

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { _ in
                OrderCardShimmerView(showAdminActions: showAdminActions)
            }
        }
        .padding(.bottom)
        .disabled(true)
        .allowsHitTesting(false)
    }
}

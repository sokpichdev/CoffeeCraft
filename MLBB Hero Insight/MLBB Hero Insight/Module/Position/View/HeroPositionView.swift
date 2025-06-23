//
//  HeroPositionView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/20/25.
//
import SwiftUI

struct HeroPositionView: View {
    @StateObject private var viewModel = HeroPositionViewModel()
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var searchText = ""
    @State private var showFilterSheet = false
    
    var filteredHeros: [HeroPositionRecord] {
        if searchText.isEmpty {
            return viewModel.positions ?? []
        } else {
            return viewModel.positions?.filter {
                $0.data?.hero?.data?.name?.localizedCaseInsensitiveContains(searchText) == true
            } ?? viewModel.positions ?? []
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Positions...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(filteredHeros.indices, id: \.self) { index in
                                let record = filteredHeros[index]
                                VStack(spacing: 0) {
                                    FlippableHeroCard(record: record)
                                        .padding(.vertical, 12)
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        Task { await viewModel.loadPosition()}
                    }
                }
            }
            .navigationTitle("Hero Positions")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .onAppear {
                Task { await viewModel.loadPosition()}
            }
        }
    }
    
    // MARK: - UI Components
}


let cardHeight: CGFloat = 220
struct FlippableHeroCard: View {
    let record: HeroPositionRecord

    @State private var isFlipped = false

    var body: some View {
        ZStack {
            frontView
                .opacity(isFlipped ? 0.0 : 1.0)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            backView
                .opacity(isFlipped ? 1.0 : 0.0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: cardHeight)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.4), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }

    // MARK: - Front Card
    private var frontView: some View {
        let hero = record.data?.hero?.data
        let aspectRatioWidth = cardHeight * 9 / 16

        return HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text(hero?.name ?? "Unknown")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text("(\(record.data?.heroID ?? 0))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let lanes = hero?.roadsort?.compactMap({ $0 }), !lanes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lanes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        WrapHStack(items: lanes, idKey: \.id) { lane in
                            badgeView(title: lane.data?.road_sort_title ?? lane.caption,
                                      iconURL: lane.data?.road_sort_icon,
                                      background: .blue.opacity(0.1))
                        }
                    }
                }

                if let roles = hero?.sortid?.compactMap({ $0 }), !roles.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Roles")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        WrapHStack(items: roles, idKey: \.id) { role in
                            badgeView(title: role.data.sort_title ?? role.caption,
                                      iconURL: role.data.sort_icon,
                                      background: .green.opacity(0.1))
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: cardHeight, alignment: .topLeading)

            // Image
            AsyncImage(url: URL(string: hero?.smallmap ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: aspectRatioWidth, height: cardHeight)
                        .clipped()
                        .frame(maxHeight: .infinity, alignment: .top)
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: aspectRatioWidth, height: cardHeight)
                        .clipped()
                        .frame(maxHeight: .infinity, alignment: .top)
                        .foregroundColor(.gray.opacity(0.5))
                case .empty:
                    ProgressView()
                        .frame(width: aspectRatioWidth, height: cardHeight)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: aspectRatioWidth, height: cardHeight)
            .shadow(radius: 2)
        }
        .frame(height: cardHeight)
        .opacity(isFlipped ? 0 : 1)
    }

    // MARK: - Back of Card
    private var backView: some View {
        let relation = record.data?.relation

        return VStack(alignment: .leading, spacing: 16) {
            Text("Hero Relations")
                .font(.title3)
                .fontWeight(.semibold)

            if let assists = relation?.assist?.target_hero_id, !assists.isEmpty {
                relationLine("🫱 Assists", ids: assists, color: .orange)
            }
            if let strongs = relation?.strong?.target_hero_id, !strongs.isEmpty {
                relationLine("💪 Strong Against", ids: strongs, color: .red)
            }
            if let weaks = relation?.weak?.target_hero_id, !weaks.isEmpty {
                relationLine("💔 Weak Against", ids: weaks, color: .purple)
            }

            Spacer()

            Text("Tap to flip back")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .opacity(isFlipped ? 1 : 0)
    }

    // MARK: - Helpers
    private func badgeView(title: String?, iconURL: String?, background: Color) -> some View {
        HStack(spacing: 4) {
            if let iconURL = iconURL {
                AsyncImage(url: URL(string: iconURL)) { phase in
                    phase.image?
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 14, height: 14)
            }
            Text(title ?? "")
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background)
        .cornerRadius(6)
    }

    private func relationLine(_ title: String, ids: [Int], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            Text(ids.map(String.init).joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct WrapHStack<Data: RandomAccessCollection, Content: View, ID: Hashable>: View {
    let items: Data
    let idKey: KeyPath<Data.Element, ID>
    let content: (Data.Element) -> Content

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        let rowSpacing: CGFloat = 5
        let maxWidth = geometry.size.width

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: idKey) { item in
                content(item)
                    .padding(.horizontal, 4)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > maxWidth {
                            width = 0
                            height -= d.height + rowSpacing
                        }
                        let result = width
                        if item[keyPath: idKey] == items.last?[keyPath: idKey] {
                            width = 0 // Last one resets
                        } else {
                            width -= d.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item[keyPath: idKey] == items.last?[keyPath: idKey] {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewHeightKey.self, value: geometry.size.height)
        }
        .onPreferenceChange(ViewHeightKey.self) { binding.wrappedValue = $0 }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

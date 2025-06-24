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
                                    FlippableHeroCard(heroes: homeVM.heroes, record: record)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
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

struct FlippableHeroCard: View {
    let heroes: [Hero]
    let record: HeroPositionRecord
    let cardHeight: CGFloat = 220
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
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
        )
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
        let heroName = record.data?.hero?.data?.name
        let relation = record.data?.relation
        
        return VStack(spacing: 8) {
            HStack {
                Text("Hero Relations")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
                Spacer()
                Text(heroName ?? "Unknown")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
            }
            .padding(.top)
            .padding(.horizontal)
            
            VStack(spacing: 6) {
                if let assists = relation?.assist?.target_hero_id, !assists.isEmpty {
                    relationSection(title: "Assists", ids: assists, dotColor: .orange)
                }
                if let strongs = relation?.strong?.target_hero_id, !strongs.isEmpty {
                    relationSection(title: "Strong Against", ids: strongs, dotColor: .green)
                }
                if let weaks = relation?.weak?.target_hero_id, !weaks.isEmpty {
                    relationSection(title: "Weak Against", ids: weaks, dotColor: .red)
                }
            }
            Spacer()
        }
        .frame(height: cardHeight)
        .background(Color(.secondarySystemBackground))
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
    
    private func relationSection(title: String, ids: [Int], dotColor: Color) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(dotColor)
                Spacer()
            }
            .padding(.leading, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    Spacer() // Trailing indentation
                        .frame(width: 16)
                    
                    ForEach(ids, id: \.self) { id in
                        if let hero = heroes.first(where: { $0.id == String(id) }) {
                            Text(hero.name)
                                .font(.subheadline)
                                .foregroundColor(dotColor)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.leading, 6)
            }
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

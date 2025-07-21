//
//  HeroDetailView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/26/25.
//
import SwiftUI

struct HeroDetailView: View {
    @StateObject var viewModel = DetailViewModel()
    let heroID: String
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    var body: some View {
        VStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if let hero = viewModel.detail.first {
                    VStack(spacing: 20) {
                        // Hero Header
                        heroHeader(hero: hero)
                        
                        // Recommended Lanes
                        lanesSection(hero: hero)
                        
                        // Skills
                        skillsSection(hero: hero)
                        
                        // Hero Relationships
                        relationshipsSection(hero: hero)
                        
                        // Story
                        storySection(hero: hero)
                    }
                    .padding()
                } else if viewModel.isFetched {
                    Text("No data found.")
                }
            }
            .task {
                await viewModel.loadDetail(id: heroID)
            }
            .navigationTitle(viewModel.detail.first?.data?.hero?.data?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.05)) {
                tabBarManager.isVisible = false
            }
        }
        .onDisappear() {
            withAnimation(.easeInOut(duration: 0.05)) {
                tabBarManager.isVisible = true
            }
        }
    }
    
    // MARK: - View Components
    
    private func heroHeader(hero: HeroDetailRecord) -> some View {
        VStack(spacing: 0) {
            // Hero Image
            AsyncImage(url: URL(string: hero.data?.head_big ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.width - 32)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.gray)
                case .empty:
                    ProgressView()
                        .frame(height: 200)
                @unknown default:
                    EmptyView()
                }
            }
            
            // Specialties
            if let specialties = hero.data?.hero?.data?.speciality, !specialties.isEmpty {
                HStack(spacing: 8) {
                    Text(specialties.count > 1 ? "Specialties:" : "Specialty:")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(specialties, id: \.self) { specialty in
                                Text(specialty)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func lanesSection(hero: HeroDetailRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Lanes")
                .font(.headline)
            
            if let lanes = hero.data?.hero?.data?.roadsort {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(lanes.indices, id: \.self) { index in
                            if let lane = lanes[index] {
                                switch lane {
                                case .roadSort(let roadSort):
                                    BadgeView(
                                        title: roadSort.data?.road_sort_title ?? roadSort.caption,
                                        iconURL: roadSort.data?.road_sort_icon,
                                        background: .blue.opacity(0.1))
                                    
                                case .string(let laneString):
                                    if !laneString.isEmpty {
                                        BadgeView(
                                            title: laneString,
                                            iconURL: nil,
                                            background: .gray.opacity(0.1))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    @ViewBuilder
    private func laneView(for lane: RoadSortItem) -> some View {
        switch lane {
        case .roadSort(let roadSort):
            VStack(spacing: 8) {
                if let iconURL = roadSort.data?.road_sort_icon, let url = URL(string: iconURL) {
                    if url.pathExtension.lowercased() == "svg" {
                        SVGImageView(url: url)
                            .frame(width: 40, height: 40)
                    } else {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            default:
                                EmptyView()
                            }
                        }
                        .frame(width: 40, height: 40)
                    }
                }
                
                Text(roadSort.data?.road_sort_title ?? roadSort.caption ?? "Unknown Lane")
                    .font(.caption)
            }
            .padding()
            .frame(width: 100)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
        case .string(let laneString):
            if !laneString.isEmpty {
                Text(laneString)
                    .font(.caption)
                    .padding()
                    .frame(width: 100)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            }
        }
    }
    
    private func skillsSection(hero: HeroDetailRecord) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.title2)
                .fontWeight(.bold)
            
            if let skillLists = hero.data?.hero?.data?.heroskilllist {
                ForEach(skillLists, id: \.skilllistid) { skillList in
                    if let skills = skillList.skilllist {
                        ForEach(skills, id: \.skillid) { skill in
                            SkillCard(skill: skill)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func relationshipsSection(hero: HeroDetailRecord) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hero Relationships")
                .font(.title2)
                .fontWeight(.bold)
            
            if let relation = hero.data?.relation {
                if let assists = relation.assist {
                    RelationshipCard(
                        title: "Works Well With",
                        description: assists.desc,
                        targetHeroes: assists.target_hero ?? [],
                        color: .green
                    )
                }
                
                if let strongs = relation.strong {
                    RelationshipCard(
                        title: "Strong Against",
                        description: strongs.desc,
                        targetHeroes: strongs.target_hero ?? [],
                        color: .blue
                    )
                }
                
                if let weaks = relation.weak {
                    RelationshipCard(
                        title: "Weak Against",
                        description: weaks.desc,
                        targetHeroes: weaks.target_hero ?? [],
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func storySection(hero: HeroDetailRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Background Story")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(hero.data?.hero?.data?.story ?? "No story available")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Subviews

struct StatView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SkillCard: View {
    let skill: HeroSkill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Skill Icon
                AsyncImage(url: URL(string: skill.skillicon ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "questionmark.circle").resizable().scaledToFit()
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 50, height: 50)
                
                // Skill Name and CD
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.skillname ?? "Unknown Skill")
                        .font(.headline)
                    
                    if let cdCost = skill.skillcdCost, !cdCost.isEmpty {
                        Text(cdCost)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Dynamic HTML View
            DynamicHTMLView(htmlContent: skill.skilldesc ?? "No description available")
                .cornerRadius(8)
            
            // Skill Tags
            if let tags = skill.skilltag, !tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.tagid) { tag in
                        Text(tag.tagname ?? "")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: tag.tagrgb ?? "79,156,184")?.opacity(0.2) ?? Color.gray.opacity(0.2))
                            .foregroundColor(Color(hex: tag.tagrgb ?? "79,156,184") ?? .gray)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
struct RelationshipCard: View {
    let title: String
    let description: String?
    let targetHeroes: [HeroImageWrapper?]?  // Optional array of optional items
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            if let description = description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let heroes = targetHeroes?.compactMap({ $0 }), !heroes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(heroes) { hero in
                            if let headUrl = hero.data?.head {
                                AsyncImage(url: URL(string: headUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        
                                    case .failure:
                                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.gray)
                                        
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 60, height: 60)
                                        
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No heroes available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
// MARK: - Helper Extensions

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color {
    init?(hex: String) {
        let rgb = hex.components(separatedBy: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        
        guard rgb.count == 3 else { return nil }
        
        let red = Double(rgb[0]) / 255.0
        let green = Double(rgb[1]) / 255.0
        let blue = Double(rgb[2]) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

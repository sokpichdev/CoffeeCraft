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
    
    var body: some View {
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
                    
                    // Stats and Attributes
                    statsSection(hero: hero)
                    
                    // Recommended Lanes
//                    lanesSection(hero: hero)
                    
                    // Skills
                    skillsSection(hero: hero)
                    
                    // Hero Relationships
//                    relationshipsSection(hero: hero)
                    
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
        .navigationTitle("Hero Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Components
    
    private func heroHeader(hero: HeroDetailRecord) -> some View {
        VStack(spacing: 16) {
            // Hero Image
            AsyncImage(url: URL(string: hero.data?.hero?.data?.squareheadbig ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
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
            
            // Hero Name and ID
            VStack(spacing: 4) {
                Text(hero.data?.hero?.data?.name ?? "Unknown Hero")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("#\(hero.data?.hero_id ?? 0)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Specialties
            if let specialties = hero.data?.hero?.data?.speciality, !specialties.isEmpty {
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
    }
    
    private func statsSection(hero: HeroDetailRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attributes")
                .font(.headline)
                .padding(.bottom, 4)
            
            if let abilities = hero.data?.hero?.data?.abilityshow {
                HStack {
                    StatView(title: "Durability", value: abilities[safe: 0] ?? "0", color: .red)
                    StatView(title: "Offense", value: abilities[safe: 1] ?? "0", color: .orange)
                    StatView(title: "Control", value: abilities[safe: 2] ?? "0", color: .blue)
                    StatView(title: "Difficulty", value: abilities[safe: 3] ?? "0", color: .purple)
                }
            }
            
            if let difficulty = hero.data?.hero?.data?.difficulty {
                HStack {
                    Text("Difficulty:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    DifficultyStars(rating: Int(difficulty) ?? 0, maxRating: 10)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
//    private func lanesSection(hero: HeroDetailRecord) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Recommended Lanes")
//                .font(.headline)
//            
//            if let lanes = hero.data?.hero?.data?.roadsort?.compactMap({ $0 }) {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(lanes, id: \.id) { lane in
//                            VStack(spacing: 8) {
//                                if let iconURL = lane.data.road_sort_icon {
//                                    AsyncImage(url: URL(string: iconURL)) { image in
//                                        image
//                                            .resizable()
//                                            .scaledToFit()
//                                    } placeholder: {
//                                        ProgressView()
//                                    }
//                                    .frame(width: 40, height: 40)
//                                }
//                                
//                                Text(lane.data?.road_sort_title ?? lane.caption ?? "")
//                                    .font(.caption)
//                            }
//                            .padding()
//                            .frame(width: 100)
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(10)
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//    }
    
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
    
//    private func relationshipsSection(hero: HeroDetailRecord) -> some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Hero Relationships")
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            if let relation = hero.data?.relation {
//                if let assists = relation.assist {
//                    RelationshipCard(
//                        title: "Works Well With",
//                        description: assists.desc,
//                        heroIDs: assists.target_hero_id ?? [],
//                        allHeroes: viewModel.allHeroes,
//                        color: .green
//                    )
//                }
//                
//                if let strongs = relation.strong {
//                    RelationshipCard(
//                        title: "Strong Against",
//                        description: strongs.desc,
//                        heroIDs: strongs.target_hero_id ?? [],
//                        allHeroes: viewModel.allHeroes,
//                        color: .blue
//                    )
//                }
//                
//                if let weaks = relation.weak {
//                    RelationshipCard(
//                        title: "Weak Against",
//                        description: weaks.desc,
//                        heroIDs: weaks.target_hero_id ?? [],
//                        allHeroes: viewModel.allHeroes,
//                        color: .red
//                    )
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//    }
    
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

struct DifficultyStars: View {
    let rating: Int
    let maxRating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
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
//struct RelationshipCard: View {
//    let title: String
//    let description: String?
//    let heroIDs: [Int]
//    let allHeroes: [Hero]
//    let color: Color
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Circle()
//                    .fill(color)
//                    .frame(width: 10, height: 10)
//                
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(color)
//                
//                Spacer()
//            }
//            
//            if let description = description {
//                Text(description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(heroIDs, id: \.self) { id in
//                        if let hero = allHeroes.first(where: { $0.id == String(id) }) {
//                            VStack(spacing: 8) {
//                                AsyncImage(url: URL(string: hero.head ?? "")) { image in
//                                    image
//                                        .resizable()
//                                        .scaledToFit()
//                                } placeholder: {
//                                    ProgressView()
//                                }
//                                .frame(width: 50, height: 50)
//                                .clipShape(Circle())
//                                
//                                Text(hero.name ?? "")
//                                    .font(.caption)
//                                    .lineLimit(1)
//                            }
//                            .frame(width: 80)
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(color.opacity(0.1))
//        .cornerRadius(10)
//    }
//}

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

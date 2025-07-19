//
//  FlippableHeroCard.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/25/25.
//
import SwiftUI

struct FlippableHeroCard: View {
    let heroes: [Hero]
    let record: HeroPositionRecord
    let cardHeight: CGFloat = 220
    
    // Tracks the total Y-axis rotation of the card.
    // 0 degrees for front, 180 or -180 for back, can accumulate beyond.
    @State private var rotationY: Double = 0.0
    
    // Used for real-time visual feedback during the drag gesture.
    @State private var liveDragRotation: Double = 0.0
    
    // The minimum horizontal swipe distance to trigger a flip.
    private let flipThreshold: CGFloat = 50.0
    
    var body: some View {
        ZStack {
            // MARK: Front View
            frontView
                .opacity(isFrontFaceVisible ? 1.0 : 0.0)
            
            // MARK: Back View
            backView
                .opacity(isBackFaceVisible ? 1.0 : 0.0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: cardHeight)
        .rotation3DEffect(
            .degrees(rotationY + liveDragRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20) // Keeping minimumDistance to aid scroll vs. swipe differentiation
                .onChanged { gesture in
                    if abs(gesture.translation.width) > abs(gesture.translation.height) {
                        self.liveDragRotation = gesture.translation.width * 0.5
                    } else {
                        self.liveDragRotation = 0
                    }
                }
                .onEnded { gesture in
                    let swipeAmount = gesture.translation.width
                    
                    if abs(swipeAmount) > abs(gesture.translation.height) && abs(swipeAmount) > flipThreshold {
                        let currentNormalizedRotation = rotationY.truncatingRemainder(dividingBy: 360)
                        let currentlyFrontFacing = (currentNormalizedRotation >= -90 && currentNormalizedRotation <= 90) ||
                                                   (currentNormalizedRotation >= 270 || currentNormalizedRotation <= -270)
                        
                        if currentlyFrontFacing {
                            if swipeAmount > 0 {
                                rotationY += 180
                            } else {
                                rotationY -= 180
                            }
                        } else {
                            if swipeAmount > 0 {
                                rotationY += 180
                            } else {
                                rotationY -= 180
                            }
                        }
                    }
                    self.liveDragRotation = 0
                }
        )
        // Handle tap gesture separately. SwiftUI's system should allow both to coexist.
        .onTapGesture {
            rotationY += 180
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: rotationY)
        .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.2), value: liveDragRotation)
    }
    
    // MARK: - View Visibility Helpers
    private var isFrontFaceVisible: Bool {
        let totalRotation = rotationY + liveDragRotation
        var adjustedRotation = totalRotation.truncatingRemainder(dividingBy: 360)
        if adjustedRotation < 0 {
            adjustedRotation += 360
        }
        return (adjustedRotation >= 0 && adjustedRotation < 90) || (adjustedRotation >= 270 && adjustedRotation < 360)
    }
    
    private var isBackFaceVisible: Bool {
        !isFrontFaceVisible
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
                                      background: .brown.opacity(0.1))
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
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
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
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
    }
    
    // MARK: - Helpers
    private func badgeView(title: String?, iconURL: String?, background: Color) -> some View {
        HStack(spacing: 4) {
            if let iconURL = iconURL, let url = URL(string: iconURL) {
                if url.pathExtension.lowercased() == "svg" {
                    SVGImageView(url: url)
                        .frame(width: 28, height: 28)
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
                    .frame(width: 20, height: 20)
                }
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

extension Double {
    func isApproximately(_ value: Double, within tolerance: Double) -> Bool {
        return abs(self - value) <= tolerance
    }
}

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
            // The front view is shown when the card is facing "forward" (0, 360, -360 degrees, etc.)
            frontView
                .opacity(isFrontFaceVisible ? 1.0 : 0.0)
            
            // MARK: Back View
            // The back view is shown when the card is facing "backward" (180, -180, 540 degrees, etc.)
            backView
                .opacity(isBackFaceVisible ? 1.0 : 0.0)
                // This internal rotation ensures the back content is readable
                // when it's rotated into the user's view (i.e., it starts "upside down" from the front's perspective).
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: cardHeight)
        // Apply the combined rotation (base rotation + live drag offset) to the entire card.
        .rotation3DEffect(
            .degrees(rotationY + liveDragRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5 // Adds a subtle 3D perspective effect
        )
        .contentShape(Rectangle()) // Makes the entire card area responsive to gestures
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Update `liveDragRotation` to provide real-time interactive tilt during the swipe.
                    // The multiplier (0.5) controls the sensitivity of this live tilt.
                    self.liveDragRotation = gesture.translation.width * 0.5
                }
                .onEnded { gesture in
                    let swipeAmount = gesture.translation.width
                    
                    if abs(swipeAmount) > flipThreshold {
                        // Determine if the card is currently showing its front face.
                        // We check the normalized angle of `rotationY` (ignoring `liveDragRotation` here,
                        // as we care about the *actual* state of the card, not just the momentary drag).
                        let currentNormalizedRotation = rotationY.truncatingRemainder(dividingBy: 360)
                        let currentlyFrontFacing = (currentNormalizedRotation >= -90 && currentNormalizedRotation <= 90) ||
                                                   (currentNormalizedRotation >= 270 || currentNormalizedRotation <= -270)
                        
                        if currentlyFrontFacing {
                            // If currently showing front:
                            if swipeAmount > 0 { // Swiped right: flip front to back by adding 180 degrees.
                                rotationY += 180
                            } else { // Swiped left: flip front to back by subtracting 180 degrees.
                                rotationY -= 180
                            }
                        } else {
                            // If currently showing back:
                            if swipeAmount > 0 { // Swiped right: flip back to front by adding 180 degrees.
                                // E.g., from -180 -> 0, or 180 -> 360 (effectively 0)
                                rotationY += 180
                            } else { // Swiped left: flip back to front by subtracting 180 degrees.
                                // E.g., from 180 -> 0, or -180 -> -360 (effectively 0)
                                rotationY -= 180
                            }
                        }
                    }
                    
                    // Reset `liveDragRotation` to 0 after the gesture ends.
                    // This allows the primary flip animation (controlled by `rotationY`) to take over smoothly.
                    self.liveDragRotation = 0
                }
        )
        .onTapGesture {
            // For a simple tap, we'll always perform a "forward" flip (adding 180 degrees).
            // You can adjust this if you want tap to mirror the last swipe direction or have a specific behavior.
            rotationY += 180
        }
        // Animate the main card flip (changes in `rotationY`).
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: rotationY)
        // Animate the interactive drag feedback more subtly and responsively.
        .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.2), value: liveDragRotation)
    }
    
    // MARK: - View Visibility Helpers
    // Determines if the front face of the card should be visible based on its current rotation.
    private var isFrontFaceVisible: Bool {
        // Calculate the total effective rotation (base + live drag) and normalize it to 0-360 degrees.
        let totalRotation = rotationY + liveDragRotation
        var adjustedRotation = totalRotation.truncatingRemainder(dividingBy: 360)
        if adjustedRotation < 0 {
            adjustedRotation += 360 // Ensure the angle is always positive
        }
        
        // The front face is visible when the card is rotated roughly between -90 and +90 degrees relative to its front.
        // This corresponds to 0-90 degrees and 270-360 degrees in the normalized [0, 360) range.
        return (adjustedRotation >= 0 && adjustedRotation < 90) || (adjustedRotation >= 270 && adjustedRotation < 360)
    }
    
    // Determines if the back face of the card should be visible. It's simply the inverse of `isFrontFaceVisible`.
    private var isBackFaceVisible: Bool {
        !isFrontFaceVisible
    }

    // MARK: - Front Card (No changes from previous)
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
    
    // MARK: - Back of Card (No changes from previous)
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
    
    // MARK: - Helpers (No changes from previous)
    private func badgeView(title: String?, iconURL: String?, background: Color) -> some View {
        HStack(spacing: 4) {
            if let iconURL = iconURL, let url = URL(string: iconURL) {
                if url.pathExtension.lowercased() == "svg" {
                    // Assuming SVGImageView is defined elsewhere in your project
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

// Extension to Double for approximate comparison, useful in visibility logic.
extension Double {
    func isApproximately(_ value: Double, within tolerance: Double) -> Bool {
        return abs(self - value) <= tolerance
    }
}

// NOTE: The previous `FlipView` struct is no longer needed and should be removed from your project.

struct FlipView<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    @Binding var isFlipped: Bool
    
    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0.0 : 1.0)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            
            back
                .opacity(isFlipped ? 1.0 : 0.0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // flips to front
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0)) // outer flip
        }
        .animation(.easeInOut(duration: 0.4), value: isFlipped)
    }
}

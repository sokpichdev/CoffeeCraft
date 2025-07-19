//
//  ContentView.swift
//  test
//
//  Created by Sok Pich on 5/13/25.
//

import SwiftUI


struct MainShimmer: View {
    var body: some View {
        ZStack {
            Color.blue
            VStack(spacing: 0) {
                HStack {
                    ShimmerView()
                        .frame(width: 40, height: 40)
                        .clipShape(.circle)
                    Spacer()
                    ShimmerView()
                        .frame(width: 30, height: 30)
                        .clipShape(.circle)
                    ShimmerView()
                        .frame(width: 70, height: 30)
                    ShimmerView()
                        .frame(width: 70, height: 30)
                }
                .padding(.horizontal, Dimens.largePadding)
                HomeShimmer()
                HStack {
                    ForEach(0..<6) { _ in
                        VStack {
                            ShimmerView()
                                .frame(width: 30, height: 30)
                            ShimmerView()
                                .frame(width: 30, height: 10)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                    }
                }
                .padding(.horizontal, Dimens.largePadding)
                .frame(height: 70)
                .background(Color.red.ignoresSafeArea())
                .cornerRadius(16, corners: [.topLeft, .topRight])
            }
        }
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct HomeShimmer: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ShimmerView()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Dimens.largePadding)
                    .frame(height: (UIScreen.screenWidth-32)/3)
                
                ShimmerView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .padding(.horizontal, Dimens.largePadding)
                HStack {
                    ForEach(0..<5) { _ in
                        VStack {
                            ShimmerView()
                                .frame(width: 40, height: 40)
                            ShimmerView()
                                .frame(width: 40, height: 10)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                    }
                }
                .padding(.horizontal, Dimens.largePadding)
                .background(Color.green)
                .border(width: 1, edges: [.bottom], color: Color.yellow)
                VStack(spacing: Dimens.gaps) {
                    HStack {
                        ShimmerView()
                            .frame(width: UIScreen.screenWidth*0.6, height: 40)
                           Spacer()
                        ShimmerView()
                            .frame(width: UIScreen.screenWidth*0.2, height: 40)
                    }.padding(.horizontal, Dimens.largePadding)
                    HStack {
                        ShimmerView()
                            .frame(maxWidth: .infinity)
                            .frame(height: (UIScreen.screenWidth-(Dimens.largePadding*2) - Dimens.gaps)/2)
                        ShimmerView()
                            .frame(maxWidth: .infinity)
                            .frame(height: (UIScreen.screenWidth-(Dimens.largePadding*2) - Dimens.gaps)/2)
                    }
                    .padding(.horizontal, Dimens.largePadding)
                    HStack {
                        ShimmerView()
                            .frame(maxWidth: .infinity)
                            .frame(height: (UIScreen.screenWidth-(Dimens.largePadding*2) - Dimens.gaps)/2)
                        ShimmerView()
                            .frame(maxWidth: .infinity)
                            .frame(height: (UIScreen.screenWidth-(Dimens.largePadding*2) - Dimens.gaps)/2)
                    }
                    .padding(.horizontal, Dimens.largePadding)
                }
            }
            .padding(.top, 7)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .clipped()
        }
    }
}


struct ShimmerView: View {
    
    @State private var startPoint: UnitPoint = .init(x: -1, y: 0.5)
    @State private var endPoint: UnitPoint = .init(x: 0, y: 0.5)
    
    private var gradientColors = [Color("B5B5B5").opacity(0.5), Color("B5B5B5").opacity(0.9), Color("B5B5B5").opacity(0.5)]
    
    var body: some View {
        LinearGradient(colors: gradientColors, startPoint: startPoint, endPoint: endPoint)
            .cornerRadius(Dimens.cornerRadius)
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    startPoint = .init(x: 1, y: 0.5)
                    endPoint = .init(x: 2, y: 0.5)
                }
            }
    }
}

class Dimens {
    // for all
    static let mediumPadding: CGFloat = 12
    static let largePadding: CGFloat = 16
    static let extraLargePadding: CGFloat = 20
    
    static let cornerRadius: CGFloat = 10
    static let largeCornerRadius: CGFloat = 16
    
    static let gaps: CGFloat = 10
}

struct BullBullDisplayView: View {
    let playerBankerName: String
    let isOnRight: Bool
    let totalHeight: CGFloat
    let cardCount = 5

    var cardSpacing: CGFloat = 4
    var containerPadding: CGFloat = 6
    var cardHeight: CGFloat { totalHeight * 0.9}
    var body: some View {
        HStack(spacing: cardSpacing) {
            // MARK: Red Box ("B")
            if isOnRight {
                leftOrRightCard
            }

            // MARK: Cards with Overlay
            ZStack(alignment: .bottom) {
                HStack(spacing: cardSpacing) {
                    ForEach(0..<cardCount, id: \.self) { index in
                        Image("101")
                            .resizable()
                            .scaledToFit()
                            .frame(height: cardHeight)
                    }
                }

                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .frame(height: cardHeight * 0.4)
                    .overlay(
                        Text("Bull Bull")
                            .font(.system(size: cardHeight * 0.4, weight: .bold))
                            .foregroundColor(Color.yellow)
                    )
            }
            if !isOnRight {
                leftOrRightCard
            }
        }
        .padding(containerPadding)
        .frame(height: totalHeight)
        .background(playerBankerName.prefix(1) == "B" ? Color.darkerRed : Color.darkerBlue)
        .overlay {
            RoundedRectangle(cornerRadius: 3)
                .stroke(
                    playerBankerName.prefix(1) == "B" ? Color.normalRed : Color.normalBlue,
                    lineWidth: 2
                )
        }
    }
    
    @ViewBuilder
    var leftOrRightCard: some View {
        // MARK: Red Box ("B")
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.1))
            
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.black.opacity(0.25), lineWidth: 4)
                .blur(radius: 3.56)
                .offset(x: 3.56, y: 3.56)
                .mask(RoundedRectangle(cornerRadius: 6))
            
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.black.opacity(0.25), lineWidth: 4)
                .blur(radius: 3.56)
                .offset(x: -3.56, y: -3.56)
                .mask(RoundedRectangle(cornerRadius: 6))
            
            if playerBankerName.count > 1 {
                let firstChar = String(playerBankerName.prefix(1))
                let secondChar = String(playerBankerName.suffix(1))
                
                VStack(spacing: 0) {
                    Text(firstChar)
                    if playerBankerName.count > 1{
                        Text(secondChar)
                    }
                }
                .font(.system(size: cardHeight * 0.4, weight: .bold))
                .foregroundColor(.white)
            } else {
                Text(playerBankerName)
                    .font(.system(size: cardHeight * 0.4, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(height: cardHeight)
        .aspectRatio(5 / 7, contentMode: .fit)
    }
}

struct NiuNiuCardsDisplayView: View {
    let totalHeight: CGFloat = UIScreen.main.bounds.height * 0.12
    let gridSpacing: CGFloat = 4
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: 2)
        
        LazyVGrid(columns: columns, spacing: gridSpacing) {
            ForEach(0..<4) { index in
                BullBullDisplayView(playerBankerName: index == 0 ? "B" : "P \(index)", isOnRight: (index + 1) % 2 == 0 ? false : true, totalHeight: (totalHeight / 2) - gridSpacing)
                    .padding(2)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .frame(height: totalHeight)
        .background(Color.muteDarkBlue)
    }
}

enum ActiveSheet: Identifiable {
    case first, second

    var id: Int {
        switch self {
        case .first: return 1
        case .second: return 2
        }
    }
}
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct DeviceSession: Identifiable {
    let id = UUID()
    let name: String
    let platform: String
    let location: String
    let status: String
    let isCurrentDevice: Bool
}

struct LinkedDevicesView: View {
    @State private var sessions: [DeviceSession] = [
        DeviceSession(name: "iPhone 13 Pro Max", platform: "Telegram iOS 11.11.1", location: "Phnom Penh, Cambodia", status: "online", isCurrentDevice: true),
        DeviceSession(name: "iMac M1", platform: "Telegram macOS 11.6 APP_STORE", location: "Phnom Penh, Cambodia", status: "1 hour ago", isCurrentDevice: false),
        DeviceSession(name: "MacBook Pro", platform: "Telegram macOS 10.9.1 APP_STORE", location: "Phnom Penh, Cambodia", status: "yesterday at 23:13", isCurrentDevice: false),
        DeviceSession(name: "G713RC", platform: "Telegram Desktop 5.14.2 x64", location: "Phnom Penh, Cambodia", status: "18/05/25", isCurrentDevice: false),
        DeviceSession(name: "Oppo F11", platform: "Telegram Android 11.4.3", location: "Phnom Penh, Cambodia", status: "14/12/24", isCurrentDevice: false),
    ]
    @State private var isEditing = false
    @State private var showAutoTerminateSheet = false
    @State private var autoTerminateOption: String = "1 month"

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "iphone.gen3")
                            .resizable()
                            .frame(width: 24, height: 40)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Link Telegram Desktop")
                                .font(.headline)
                            Text("Scan a QR code to link device")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("This Device"), footer: Text("Logs out all devices except for this one.")) {
                    if let currentDevice = sessions.first(where: { $0.isCurrentDevice }) {
                        DeviceRow(session: currentDevice)
                    }

                    Button(action: {
                        sessions.removeAll(where: { !$0.isCurrentDevice })
                    }) {
                        Text("Terminate all other sessions")
                            .foregroundColor(.red)
                    }
                }
                
                Section(
                    header: Text("Active Sessions"),
                    footer: Text("This official Telegram app is available for iPhone, iPad, Android, and Windows, macOS and Linux. Learn More")
                ) {
                    ForEach(sessions.filter { !$0.isCurrentDevice }) { session in
                        HStack {
                            if isEditing {
                                Button(action: {
                                    if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                                        sessions.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            DeviceRow(session: session)
                            Spacer()
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                                    sessions.remove(at: index)
                                }
                            } label: {
                                Label("Terminate", systemImage: "trash")
                            }
                        }
                    }
                }
                
                Section(header: Text("AUTOMATICALLY TERMINATE OLD SESSIONS")) {
                    Button(action: {
                        showAutoTerminateSheet = true
                    }) {
                        HStack {
                            Text("If inactive for")
                            Spacer()
                            Text(autoTerminateOption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showAutoTerminateSheet) {
            AutoTerminateSheet(selectedOption: $autoTerminateOption)
                .presentationDetents([.fraction(0.3), .medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct DeviceRow: View {
    let session: DeviceSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.name)
                .font(.headline)
            Text(session.platform)
                .font(.subheadline)
            Text("\(session.location) • \(session.status)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct AutoTerminateSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedOption: String
    let options = ["1 week", "2 weeks", "1 month", "3 months", "Never"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    HStack {
                        Text(option)
                        Spacer()
                        if option == selectedOption {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOption = option
                        dismiss()
                    }
                }
            }
        }
    }
}

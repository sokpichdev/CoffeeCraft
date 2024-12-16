import SwiftUI

struct StatsView: View {
    
    let statsData: [(String, Int, Int)] = [
        ("Total Shots", 23, 11),
        ("Shots on Target", 8, 4),
        ("Shots off Target", 9, 5),
        ("Blocked Shots", 6, 2),
        ("Big Chances Created", 4, 2),
        ("Big Chances Missed", 4, 0),
        ("Shots-Inside The Box", 16, 7),
        ("Shots-Outside The Box", 16, 7),
        ("Goal", 4, 2)
    ]
    
    // Calculate the total points for all stats
    var totalLeftPoints: Int {
        statsData.reduce(0) { $0 + $1.1 }
    }
    
    var totalRightPoints: Int {
        statsData.reduce(0) { $0 + $1.2 }
    }
    
    // Calculate % of points
    var leftPercentage: Double {
        let totalPoints = totalLeftPoints + totalRightPoints
        return totalPoints == 0 ? 0.0 : Double(totalLeftPoints) / Double(totalPoints)
    }
    
    var rightPercentage: Double {
        return 1.0 - leftPercentage
    }
    
    var body: some View {
        VStack {
            //            VStack{
            //                    // Place ProgressView on top of everything
            //                    ProgressView(value: leftPercentage, total: 1.0, label: {}, currentValueLabel: {
            //                        HStack {
            //                            Text("\(Int(leftPercentage * 100))%")
            //                                .font(.headline)
            //                                .foregroundColor(.white)
            //                                .frame(maxWidth: .infinity, alignment: .leading)
            //                                .padding(.leading, 16)
            //
            //                            Text("\(Int(rightPercentage * 100))%")
            //                                .font(.headline)
            //                                .foregroundColor(.white)
            //                                .frame(maxWidth: .infinity, alignment: .trailing)
            //                                .padding(.trailing, 16)
            //                        }
            //                    })
            //                    .progressViewStyle(BarProgressStyle(height: 25))
            //                    .background(Color.percentage)
            //                    .cornerRadius(15)
            //                    .padding(.horizontal, 16)
            //                }
            //                .frame(maxWidth: .infinity)
            //                .frame(height: 25)
            //                .padding(16)
            
            VStack {
                ZStack {
                    HStack(spacing: 0) {
                        HStack {/* No content inside, just the background color*/}
                        .frame(width: (UIScreen.main.bounds.width-64) * leftPercentage, height: 25)
                        .background(Color.main)
                         HStack {}
                        .frame(width: (UIScreen.main.bounds.width-64) * rightPercentage, height: 25)
                        .background(Color.optionBtn2)
                    }
                    .cornerRadius(10)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Text("\(Int(leftPercentage * 100))%")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        
                        Text("\(Int(rightPercentage * 100))%")
                            .font(.headline)
                            .foregroundColor(.letters)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 16)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                }
            }
            //                        .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                StatsDetailView(team: "Team", leftTeamPoint: "North Koreaaaaaaa", rightTeamPoint: "South Korea")
                    .background(Color.optionBtn2)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                ForEach(0..<statsData.count, id: \.self) { index in
                    StatsDetailView(
                        team: statsData[index].0,
                        leftTeamPoint: "\(statsData[index].1)",
                        rightTeamPoint: "\(statsData[index].2)"
                    )
                    Divider()
                }
            }
            .background(Color.optionBtn1)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.letters.opacity(0.2), lineWidth: 3))
            .cornerRadius(10)
            .padding(10)
        }
        .background(Color.optionBtn1.opacity(1.5))
        .cornerRadius(10)
        .padding(16)
    }
}

struct StatsDetailView: View {
    let team: String
    let leftTeamPoint: String
    let rightTeamPoint: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(team)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            Text(leftTeamPoint)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(rightTeamPoint)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.letters)
        .font(.caption2)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StatsView()
}

import SwiftUI

struct StatsView: View {
    @ObservedObject var mDVM: MatchDetailViewModel
    
    // Calculate the total points for all stats
    var totalLeftPoints: Int {
        mDVM.mDVM.stats!.reduce(into: 0) { total, stat in
            // Convert the .home value (String) into Int, using optional binding
            let leftPoints = Int(stat.home ?? "0") ?? 0
            total += leftPoints // Modify total directly
        }
    }

    var totalRightPoints: Int {
        mDVM.mDVM.stats!.reduce(into: 0) { total, stat in
            let rightPoints = Int(stat.away ?? "0") ?? 0
            total += rightPoints
        }
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
        if let stats = mDVM.mDVM.stats, !stats.isEmpty{
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
            
            VStack(spacing: 0) {
                // Display the team names (first entry)
                StatsDetailView(team: "Team",
                                leftTeamPoint: mDVM.mDVM.stats?[0].home ?? "0",
                                rightTeamPoint: mDVM.mDVM.stats?[0].away ?? "0")
                .background(Color.optionBtn2)
                .font(.subheadline)
                .fontWeight(.bold)
                
                // Display the rest of the stats data, starting from the second entry
                ForEach(mDVM.mDVM.stats?.dropFirst() ?? [], id: \.name) { stat in
                    StatsDetailView(
                        team: stat.name ?? "Unknown",  // Use `name` or another unique property
                        leftTeamPoint: stat.home ?? "0",
                        rightTeamPoint: stat.away ?? "0"
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
        } else {
            NoDataView()
        }
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

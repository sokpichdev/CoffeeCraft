//
//  MatchesModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/20/24.
//
//
//  MatchesModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/20/24.
//

import Foundation

extension MatchesModel: CustomDebugStringConvertible {
    var debugDescription: String {
        let matchDetails = matches?.map { $0.debugDescription }.joined(separator: "\n") ?? "No match details"
        let sportDescription = sport?.debugDescription ?? "No sport data"
        
        return """
        \n
        MatchesModel:
        - ID: \(id ?? 0)
        - Icon: \(icon ?? "N/A")
        - IsCup: \(isCup ?? 0)
        - Name: \(name ?? "N/A")
        - Country: \(country ?? "N/A")
        - Favorite: \(favorite ?? false)
        - Sport:
        \(sportDescription)
        - Matches:
        \(matchDetails)\n
        """
    }
}

extension MatchDetailModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return """
            MatchDetailModel:
        -       ID: \(id ?? 0)
        -       League ID: \(leagueID ?? 0)
        -       Date: \(date ?? "N/A")
        -       Status: \(status ?? "N/A")
        -       Time: \(time ?? "N/A")
        -       Home Team Score: \(homeTeamScore ?? "N/A")
        -       Away Team Score: \(awayTeamScore ?? "N/A")
                --------------------\n
        """
    }
}

extension Sport: CustomDebugStringConvertible {
    var debugDescription: String {
        return """
        -   ID: \(id ?? 0)
        -   Name: \(name ?? "N/A")
        -   Icon: \(icon ?? "N/A")
        -   Active Icon: \(activeIcon ?? "N/A")
        """
    }
}

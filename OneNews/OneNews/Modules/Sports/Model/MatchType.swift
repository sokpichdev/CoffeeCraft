//
//  MatchType.swift
//  OneNews
//
//  Created by Sok Pich on 12/19/24.
//

import SwiftUI

enum MatchType: String, Codable{
    case none
    case live = "live"
    case fixtures = "fixtures"
    case results = "results"
}

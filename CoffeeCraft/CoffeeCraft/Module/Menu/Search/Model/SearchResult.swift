//
//  SearchResult.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/16/26.
//
import SwiftUI

struct SearchResult {
        let product: Product
        let matchType: MatchType
        
        enum MatchType {
            case name
            case category
            case description
            case price
        }
    }

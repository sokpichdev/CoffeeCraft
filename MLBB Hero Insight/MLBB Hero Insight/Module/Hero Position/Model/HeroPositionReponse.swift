//
//  HeroPositionReponse.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/20/25.
//

import Foundation
struct HeroPositionReponse: Codable {
    let code: Int?
    let message: String?
    let data: HeroDataContainer?
}

struct HeroDataContainer: Codable {
    let records: [HeroPositionRecord]?
    let total: Int?
}

struct HeroPositionRecord: Codable {
    let data: HeroRecordData?
    let id: Int?
}

struct HeroRecordData: Codable {
    let hero: HeroWrapper?
    let heroID: Int?
    let relation: HeroRelation?
    
    enum CodingKeys: String, CodingKey {
        case heroID = "hero_id"
        case hero, relation
    }
}

struct HeroWrapper: Codable {
    let data: HeroDetail?
}

struct HeroDetail: Codable {
    let name: String?
    let roadsort: [HeroRoadSort]?
    let smallmap: String?
    let sortid: [HeroSortID]?
}

struct HeroRoadSort: Codable {
    let _id: String?
    let caption: String?
    let configId: Int?
    let createdAt: Int?
    let createdUser: String?
    let data: RoadSortData?
    let dynamic: String?
    let id: Int?
    let linkId: [Int]?
    let sort: Int?
    let updatedAt: Int?
    let updatedUser: String?
}

struct RoadSortData: Codable {
    let _object: Int?
    let road_sort_icon: String?
    let road_sort_id: String?
    let road_sort_title: String?
}

struct HeroSortID: Codable {
    let _id: String?
    let caption: String?
    let configId: Int?
    let createdAt: Int64?
    let createdUser: String?
    let data: SortIDData
    let dynamic: String?
    let id: Int?
    let linkId: [Int]?
    let sort: Int?
    let updatedAt: Int?
    let updatedUser: String?
}

struct SortIDData: Codable {
    let _object: Int?
    let sort_icon: String?
    let sort_id: String?
    let sort_title: String?
}

struct HeroRelation: Codable {
    let assist: HeroTargetRelation?
    let strong: HeroTargetRelation?
    let weak: HeroTargetRelation?
}

struct HeroTargetRelation: Codable {
    let target_hero_id: [Int]?
}

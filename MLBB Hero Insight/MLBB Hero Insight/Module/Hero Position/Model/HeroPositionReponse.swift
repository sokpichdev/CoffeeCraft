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

struct HeroPositionRecord: Identifiable, Codable {
    let data: HeroRecordData?
    let id: Int?
    //    var id: Int { data?.heroID ?? 0}
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

    enum CodingKeys: String, CodingKey {
        case name, roadsort, smallmap, sortid
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.smallmap = try? container.decode(String.self, forKey: .smallmap)

        // Decode roadsort safely
        if var roadsortArray = try? container.nestedUnkeyedContainer(forKey: .roadsort) {
            var tempRoadsort: [HeroRoadSort] = []
            while !roadsortArray.isAtEnd {
                if let item = try? roadsortArray.decode(HeroRoadSort.self) {
                    tempRoadsort.append(item)
                } else {
                    _ = try? roadsortArray.decode(DummyCodable.self) // skip invalid
                }
            }
            self.roadsort = tempRoadsort
        } else {
            self.roadsort = nil
        }

        // Decode sortid safely
        if var sortidArray = try? container.nestedUnkeyedContainer(forKey: .sortid) {
            var tempSortid: [HeroSortID] = []
            while !sortidArray.isAtEnd {
                if let item = try? sortidArray.decode(HeroSortID.self) {
                    tempSortid.append(item)
                } else {
                    _ = try? sortidArray.decode(DummyCodable.self) // skip invalid
                }
            }
            self.sortid = tempSortid
        } else {
            self.sortid = nil
        }
    }
}

// A dummy type to discard invalid values
private struct DummyCodable: Codable {}

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
    let createdAt: Int?
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

//
//  Detail.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/26/25.
//
import SwiftUI

// ✅ Top-Level Response Model
struct HeroResponse: Codable {
    let code: Int?
    let message: String?
    let data: HeroDetailDataContainer?
}

struct HeroDetailDataContainer: Codable {
    let records: [HeroDetailRecord]?
    let total: Int?
}

// ✅ Main Record Model
struct HeroDetailRecord: Codable, Identifiable {
    let id: Int?
    let _id: String?
    let caption: String?
    let configId: Int?
    let createdAt: Int?
    let createdUser: String?
    let data: HeroDetailRecordData?
    let updatedAt: Int?
    let updatedUser: String?
    let sort: Int?
    let linkId: [Int]?
}

// ✅ Hero Metadata
struct HeroDetailRecordData: Codable {
    let _object: Int?
    let head: String?
    let head_big: String?
    let hero: HeroCoreData?
    let hero_id: Int?
    let relation: HeroDetailRelation?
}

// ✅ Hero Core Info
struct HeroCoreData: Codable {
    let _createdAt: Int?
    let _id: String?
    let _updatedAt: Int?
    let data: HeroDetails?
    let id: Int?
    let sourceId: Int?
}

// ✅ Hero Details
struct HeroDetails: Codable {
    let abilityshow: [String]?
    let difficulty: String?
    let head: String?
    let heroid: Int?
    let heroskilllist: [HeroSkillContainer]?
    let name: String?
    let painting: String?
    let recommendlevel: [String]?
    let recommendlevellabel: String?
    let roadsort: [RoadSortItem?]?
    let roadsorticon1: String?
    let roadsorticon2: String?
    let roadsortlabel: [String]?
    let smallmap: String?
    let sorticon1: String?
    let sorticon2: String?
    let sortid: [HeroSortID?]?
    let sortlabel: [String]?
    let speciality: [String]?
    let squarehead: String?
    let squareheadbig: String?
    let story: String?
    let tale: String?
}

enum RoadSortItem: Codable {
    case roadSort(HeroRoadSort)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let roadSort = try? container.decode(HeroRoadSort.self) {
            self = .roadSort(roadSort)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            throw DecodingError.typeMismatch(RoadSortItem.self,
                                           DecodingError.Context(codingPath: decoder.codingPath,
                                           debugDescription: "Expected HeroRoadSort or String"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .roadSort(let roadSort):
            try container.encode(roadSort)
        case .string(let string):
            try container.encode(string)
        }
    }
}

// ✅ Hero Skill Info
struct HeroSkillContainer: Codable {
    let skilllist: [HeroSkill]?
    let skilllistid: String?
}

struct HeroSkill: Codable {
    let skillcdCost: String?
    let skilldesc: String?
    let skillicon: String?
    let skillid: Int?
    let skillname: String?
    let skilltag: [HeroSkillTag]?
    let skillvideo: String?

    private enum CodingKeys: String, CodingKey {
        case skillcdCost = "skillcd&cost"
        case skilldesc, skillicon, skillid, skillname, skilltag, skillvideo
    }
}

struct HeroSkillTag: Codable {
    let tagid: Int?
    let tagname: String?
    let tagrgb: String?
}

// ✅ Hero Relationship Info
struct HeroDetailRelation: Codable {
    let assist: HeroRelationType?
    let strong: HeroRelationType?
    let weak: HeroRelationType?
}

struct HeroRelationType: Codable {
    let desc: String?
    let target_hero: [HeroImageWrapper?]?
    let target_hero_id: [Int]?
}

// Wrapper for "target_hero" items which can be either an object or a string/other invalid type
struct HeroImageWrapper: Codable, Identifiable {
    // Add an id for ForEach convenience; use UUID if no id in JSON
    let id = UUID()
    let data: HeroImage?

    struct HeroImage: Codable {
        let head: String?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Try decode as dictionary with "data" key
        if let obj = try? container.decode([String: HeroImage].self) {
            self.data = obj["data"]
        } else {
            // If decoding fails (string, number, etc), assign nil
            self.data = nil
        }
    }
}

struct HeroImageData: Codable {
    let head: String?
}

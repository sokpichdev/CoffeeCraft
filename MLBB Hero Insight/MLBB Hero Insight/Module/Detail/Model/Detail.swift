//
//  Detail.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/26/25.
//
import SwiftUI

// ✅ Top-Level Response Model
struct HeroResponse: Codable {
    let code: Int
    let message: String
    let data: HeroDetailDataContainer
}

struct HeroDetailDataContainer: Codable {
    let records: [HeroDetailRecord]
    let total: Int
}

// ✅ Main Record Model
struct HeroDetailRecord: Codable, Identifiable {
    let id: Int
    let _id: String
    let caption: String
    let configId: Int
    let createdAt: Int64
    let createdUser: String
    let data: HeroDetailRecordData
    let updatedAt: Int64
    let updatedUser: String
}

// ✅ Hero Metadata
struct HeroDetailRecordData: Codable {
    let _object: Int
    let head: URL
    let head_big: URL
    let hero: HeroCoreData
    let hero_id: Int
    let relation: HeroRelation
    let url: URL
}

// ✅ Hero Core Info
struct HeroCoreData: Codable {
    let _createdAt: Int64
    let _id: String
    let _updatedAt: Int64
    let data: HeroDetails
    let id: Int
    let sourceId: Int
}

// ✅ Hero Details
struct HeroDetails: Codable {
    let abilityshow: [String]
    let difficulty: String
    let head: URL
    let heroid: Int
    let heroskilllist: [HeroSkillContainer]
    let name: String
    let painting: URL
    let recommendlevel: [String]
    let recommendlevellabel: String
    let roadsort: [HeroRoadSort?]
    let roadsorticon1: URL
    let roadsorticon2: String
    let roadsortlabel: [String]
    let smallmap: URL
    let sorticon1: URL
    let sorticon2: String
    let sortid: [HeroSortID?]
    let sortlabel: [String]
    let speciality: [String]
    let squarehead: URL
    let squareheadbig: URL
    let story: String
    let tale: String?
}

// ✅ Hero Skill Info
struct HeroSkillContainer: Codable {
    let skilllist: [HeroSkill]
    let skilllistid: String
}

struct HeroSkill: Codable {
    let skillcdCost: String
    let skilldesc: String
    let skillicon: URL
    let skillid: Int
    let skillname: String
    let skilltag: [HeroSkillTag]
    let skillvideo: String

    private enum CodingKeys: String, CodingKey {
        case skillcdCost = "skillcd&cost"
        case skilldesc, skillicon, skillid, skillname, skilltag, skillvideo
    }
}

struct HeroSkillTag: Codable {
    let tagid: Int
    let tagname: String
    let tagrgb: String
}

// ✅ Hero Relationship Info
struct HeroDetailRelation: Codable {
    let assist: HeroRelationType
    let strong: HeroRelationType
    let weak: HeroRelationType
}

struct HeroRelationType: Codable {
    let desc: String
    let target_hero: [HeroImageWrapper?]
    let target_hero_id: [Int]
}

struct HeroImageWrapper: Codable {
    let data: HeroImageData
}

struct HeroImageData: Codable {
    let head: URL
}

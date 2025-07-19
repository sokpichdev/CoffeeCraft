//
//  HeroRankResponse.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/18/25.
//
import SwiftUI

struct HeroRankingResponse: Decodable {
    let code: Int?
    let message: String?
    let data: HeroRankingData?
}

struct HeroRankingData: Decodable {
    let records: [HeroRankingRecord]?
    let total: Int?
}

struct HeroRankingRecord: Identifiable, Decodable {
    var id: Int { data.mainHeroId ?? 0 }
    let data: HeroRankingDetail
}

struct HeroRankingDetail: Decodable {
    let mainHero: HeroDataWrapper?
    let mainHeroAppearanceRate: Double?
    let mainHeroBanRate: Double?
    let mainHeroChannel: ChannelInfo?
    let mainHeroWinRate: Double?
    let mainHeroId: Int?
    let subHero: [SubHero]?

    enum CodingKeys: String, CodingKey {
        case mainHero = "main_hero"
        case mainHeroAppearanceRate = "main_hero_appearance_rate"
        case mainHeroBanRate = "main_hero_ban_rate"
        case mainHeroChannel = "main_hero_channel"
        case mainHeroWinRate = "main_hero_win_rate"
        case mainHeroId = "main_heroid"
        case subHero = "sub_hero"
    }
}

struct HeroDataWrapper: Decodable {
    let data: HeroBasicInfo?
}

struct HeroBasicInfo: Decodable {
    let head: String?
    let name: String?
}

struct ChannelInfo: Decodable {
    let id: Int?
}

struct SubHero: Decodable {
    let hero: HeroDataWrapper?
    let heroChannel: ChannelInfo?
    let heroId: Int?
    let increaseWinRate: Double?

    enum CodingKeys: String, CodingKey {
        case hero
        case heroChannel = "hero_channel"
        case heroId = "heroid"
        case increaseWinRate = "increase_win_rate"
    }
}

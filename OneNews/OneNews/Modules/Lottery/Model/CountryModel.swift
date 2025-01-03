//
//  CountryModel.swift
//  OneNews
//
//  Created by Sok Pich on 1/3/25.
//

struct CountryModel: Codable {
    var countryID: Int?
    var order: Int?
    var isEnabled: Bool?
    var country: CountryDetail?
    
    enum CodingKeys: String, CodingKey {
        case countryID = "country_id"
        case order, country
        case isEnabled = "is_enabled"
    }
    
    struct CountryDetail: Codable, Identifiable{
        var id: Int?
        var name: String?
        var flag: String?
        var lotteriesCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case id, name, flag
            case lotteriesCount = "lotteries_count"
        }
    }
}

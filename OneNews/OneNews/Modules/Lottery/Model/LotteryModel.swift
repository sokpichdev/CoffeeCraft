//
//  LotteryModel.swift.swift
//  OneNews
//
//  Created by Sok Pich on 1/2/25.
//

struct LotteryModel: Codable, Identifiable {
    var id: Int?
    var title: String?
    var lotteryCategoryID: Int?
    var openDate: String?
    var icon: String?
    var result: LotteryResultModel?
    var favorite: Bool?
    var isPrediction: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, icon, result, favorite
        case lotteryCategoryID = "lottery_category_id"
        case openDate = "opendate"
        case isPrediction = "is_prediction"
    }
}


struct LotteryResultModel: Codable {
    var lotteryListID: Int?
    var openDate: String?
    var detail: Detail?
    
    private enum CodingKeys: String, CodingKey {
        case lotteryListID = "lottery_list_id"
        case openDate = "opendate"
        case detail
    }
    
    struct Detail: Codable {
        var code: String?
        var issue: String?
        var officialIssue: String?
        
        private enum CodingKeys: String, CodingKey {
            case code, issue
            case officialIssue = "officialissue"
        }
    }
}

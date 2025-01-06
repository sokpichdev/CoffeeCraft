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
    
}

// MARK: - Detail
struct Detail: Codable {
    // when lottery_category_id = 3
    let issue, officialissue: String?
    
    // when lottery_category_id = 4
    let code: CodeType?
   
    enum CodingKeys: String, CodingKey {
        case code, issue, officialissue
    }
}

struct CodeLottery7: Codable {
    var code, code1: String?
    var code2, code3, code4, code5, code6, code7: [String]?
}

struct CodeLottery8: Codable {
    var code, code1, code2: String?
    var code3, code4, code5, code6, code7, code8: [String]?
}
enum CodeType: Codable {
    case lottery7(CodeLottery7)
    case lottery8(CodeLottery8)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let lottery = try? container.decode(CodeLottery7.self) {
            self = .lottery7(lottery)
        } else if let lottery = try? container.decode(CodeLottery8.self) {
            self = .lottery8(lottery)
        } else if let stringCode = try? container.decode(String.self) {
            self = .string(stringCode)
        } else {
            throw DecodingError.typeMismatch(CodeType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode CodeType"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .lottery7(let lottery):
            try container.encode(lottery)
        case .lottery8(let lottery):
            try container.encode(lottery)
        case .string(let stringCode):
            try container.encode(stringCode)
        }
    }
}

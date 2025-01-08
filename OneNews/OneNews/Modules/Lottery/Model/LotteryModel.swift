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
    var code: CodeType?
    
    // when lottery_category_id = 5
    var c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 : String?
    var s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 : String?
    var p1, p2, p3 : String?
    var jp1, jp2, jp3 : String?
    var estjp1, estjp2, estjp3 : String?
    var jp1won, jp2won, jp3won : String?
    var dn, complete4d: String?
   
    enum CodingKeys: String, CodingKey {
        case code, issue, officialissue
        case c1 = "C1"
        case c2 = "C2"
        case c3 = "C3"
        case c4 = "C4"
        case c5 = "C5"
        case c6 = "C6"
        case c7 = "C7"
        case c8 = "C8"
        case c9 = "C9"
        case c10 = "C10"
        
        case s1 = "S1"
        case s2 = "S2"
        case s3 = "S3"
        case s4 = "S4"
        case s5 = "S5"
        case s6 = "S6"
        case s7 = "S7"
        case s8 = "S8"
        case s9 = "S9"
        case s10 = "S10"
        
        case p1 = "P1"
        case p2 = "P2"
        case p3 = "P3"
        
        case jp1 = "JP1"
        case jp2 = "JP2"
        case jp3 = "JP3"
        
        case estjp1 = "ESTJP1"
        case estjp2 = "ESTJP2"
        case estjp3 = "ESTJP3"
        
        case jp1won = "JP1WON"
        case jp2won = "JP2WON"
        case jp3won = "JP3WON"
        
        case dn = "DN"
        case complete4d = "COMPLETE4D"
    }
}

struct CodeLottery7: Codable {
    var code, code1: String?
    var code2, code3, code4, code5, code6, code7: [String]?
}

struct CodeLottery8: Codable {
    var code, code1, code2, code5, code7, code8: String?
    var code3, code4, code6: [String]?
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

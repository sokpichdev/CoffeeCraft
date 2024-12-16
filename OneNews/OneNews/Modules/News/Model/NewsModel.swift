//
//  NewsModel.swift
//  OneNews
//
//  Created by Sok Pich on 12/4/24.
//

import SwiftUI

struct NewsModel {
    let image: String
    let title: String
    let type: NewsType
}

enum NewsType: Int {
    case football = 1
    case basketball = 2
    case lottery = 3
}

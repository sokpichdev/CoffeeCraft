//
//  Announcement.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 2/11/26.
//


//
//  Announcement.swift
//  CoffeeCraft
//
//  Created by Claude on 2/11/26.
//

import Foundation
import FirebaseFirestore

struct Announcement: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String?
    let description: String?
    let imageName: String?
    let createdDate: Timestamp?
//    var isRead: Bool = false
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageName
        case createdDate
//        case isRead
    }
    
    // Computed property for display date
    var displayDate: String {
        guard let timestamp = createdDate else { return "" }
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Computed property for relative date (e.g., "2 hours ago")
    var relativeDate: String {
        guard let timestamp = createdDate else { return "" }
        let date = timestamp.dateValue()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

//
//  UserRole.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 10/20/25.
//
import Foundation

enum UserRole: String, Codable {
    case customer
    case manager
}

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var role: UserRole
}

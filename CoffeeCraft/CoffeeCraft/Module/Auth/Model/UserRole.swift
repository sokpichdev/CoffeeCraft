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

struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var email: String
    var role: UserRole
    
    /// optional fields
    var phoneNumber: String?
    var gender: String?
    var dateOfBirth: Date?
    var city: String?
}

struct FieldValidation {
    var isValid: Bool = true
    var message: String = ""
}

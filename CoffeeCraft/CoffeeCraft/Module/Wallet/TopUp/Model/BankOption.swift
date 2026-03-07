//
//  BankOption.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/7/26.
//
import SwiftUI

struct BankOption: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
}

let bankOptions: [BankOption] = [
    BankOption(id: "aba", name: "ABA Bank",
               icon: "building.columns.fill", color: .blue,
               description: "Scan & Pay via ABA Mobile"),
    
    BankOption(id: "vattanac", name: "Vattanac Bank",
               icon: "building.columns.fill", color: Color(hex: "1A56DB"),
               description: "Scan & Pay via Vattanac Mobile"),
    
    BankOption(id: "acleda", name: "ACLEDA Bank",
               icon: "building.columns.fill", color: .orange,
               description: "Scan & Pay via ACLEDA Unity"),
    
    BankOption(id: "wing", name: "Wing Bank",
               icon: "w.circle.fill", color: .green,
               description: "Scan & Pay via Wing Mobile")
]

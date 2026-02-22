//
//  NetworkMonitor.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 22/02/2026.
//


import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor() // make it accessable as singleton class
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

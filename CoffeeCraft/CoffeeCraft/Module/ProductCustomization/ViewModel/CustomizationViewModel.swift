//
//  CustomizationViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//

import Foundation
import FirebaseFirestore
import Combine

class CustomizationViewModel: ObservableObject {
    @Published var availableCustomizations: [CustomizationCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        fetchCustomizations()
    }
    
    // Fetch all customization categories from Firestore
    func fetchCustomizations() {
        isLoading = true
        
        db.collection("customizations").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Failed to load customizations: \(error.localizedDescription)"
                print("❌ Error fetching customizations: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.errorMessage = "No customizations found"
                return
            }
            
            self.availableCustomizations = documents.compactMap { doc -> CustomizationCategory? in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let optionsData = data["options"] as? [[String: Any]] else {
                    return nil
                }
                
                let options = optionsData.compactMap { optionDict -> CustomizationOption? in
                    guard let optionName = optionDict["name"] as? String,
                          let price = optionDict["price"] as? Double else {
                        return nil
                    }
                    return CustomizationOption(name: optionName, price: price)
                }
                
                return CustomizationCategory(name: name, options: options)
            }.sorted { $0.name < $1.name }
            
            print("✅ Loaded \(self.availableCustomizations.count) customization categories")
        }
    }
    
    // Save a new customization category to Firestore
    func saveCustomization(_ category: CustomizationCategory) async {
        let customID = category.name.lowercased().replacingOccurrences(of: " ", with: "_")
        
        let options = category.options.map { option in
            ["name": option.name, "price": option.price]
        }
        
        let data: [String: Any] = [
            "name": category.name,
            "options": options
        ]
        
        do {
            try await db.collection("customizations").document(customID).setData(data)
            print("✅ Saved customization: \(category.name)")
            
            // Refresh the list
            await MainActor.run {
                fetchCustomizations()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to save customization: \(error.localizedDescription)"
            }
            print("❌ Error saving customization: \(error.localizedDescription)")
        }
    }
    
    // Delete a customization category from Firestore
    func deleteCustomization(_ category: CustomizationCategory) async {
        let customID = category.name.lowercased().replacingOccurrences(of: " ", with: "_")
        
        do {
            try await db.collection("customizations").document(customID).delete()
            print("✅ Deleted customization: \(category.name)")
            
            // Refresh the list
            await MainActor.run {
                fetchCustomizations()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete customization: \(error.localizedDescription)"
            }
            print("❌ Error deleting customization: \(error.localizedDescription)")
        }
    }
}

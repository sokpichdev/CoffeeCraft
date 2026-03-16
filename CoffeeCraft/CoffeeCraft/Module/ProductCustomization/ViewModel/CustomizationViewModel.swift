//
//  CustomizationViewModel.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/17/26.
//

import Combine
import FirebaseFirestore
import Foundation

@MainActor
class CustomizationViewModel: ObservableObject {
    @Published var availableCustomizations: [CustomizationCategory] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    // Fetch all customization categories from Firestore
    func fetchCustomizations() {
        isLoading = true
        AppLog.menu.debug("🔍 fetchCustomizations — fetching all customization categories")

        db.collection("customizations").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoading = false
                
                if let error = error {
                    AppLog.menu.error("❌ fetchCustomizations — error: \(error.localizedDescription)")
                    AlertManager.shared.showError(title: "Failed to load customizations",
                                                  message: error.localizedDescription)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    AppLog.menu.warning("⚠️ fetchCustomizations — snapshot has no documents")
                    AlertManager.shared.showError(message: "No customizations found")
                    return
                }
                
                self.availableCustomizations = documents.compactMap { doc -> CustomizationCategory? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let optionsData = data["options"] as? [[String: Any]] else {
                        AppLog.menu.warning("⚠️ fetchCustomizations — skipped malformed doc: \(doc.documentID)")
                        return nil
                    }
                    
                    let options = optionsData.compactMap { optionDict -> CustomizationOption? in
                        guard let optionName = optionDict["name"] as? String,
                              let price = optionDict["price"] as? Double else {
                            AppLog.menu.warning("""
                                                ⚠️ fetchCustomizations — skipped \
                                                malformed option in doc: \(doc.documentID)
                                                """)
                            return nil
                        }
                        return CustomizationOption(name: optionName, price: price)
                    }
                    
                    return CustomizationCategory(name: name, options: options)
                }.sorted { $0.name < $1.name }

                AppLog.menu.debug("✅ fetchCustomizations — loaded \(self.availableCustomizations.count) category(s)")
                AppLog.printList(self.availableCustomizations, label: "Customization Categories", logger: AppLog.menu)
            }
        }
    }
    
    // Save a new customization category to Firestore
    func saveCustomization(_ category: CustomizationCategory) async {
        let customID = category.name.lowercased().replacingOccurrences(of: " ", with: "_")
        AppLog.menu.debug("""
                          💾 saveCustomization — name: \(category.name), \
                          docId: \(customID), options: \(category.options.count)
                          """)

        let options = category.options.map { option in
            ["name": option.name, "price": option.price]
        }
        
        let data: [String: Any] = [
            "name": category.name,
            "options": options
        ]
        
        do {
            try await db.collection("customizations").document(customID).setData(data)
            AppLog.menu.debug("✅ saveCustomization — saved: \(category.name)")
            fetchCustomizations()
        } catch {
            AppLog.menu.error("❌ saveCustomization — failed for \(category.name): \(error.localizedDescription)")
            AlertManager.shared.showError(title: "Failed to save customization", message: error.localizedDescription)
        }
    }
    
    // Delete a customization category from Firestore
    func deleteCustomization(_ category: CustomizationCategory) async {
        let customID = category.name.lowercased().replacingOccurrences(of: " ", with: "_")
        AppLog.menu.debug("🗑️ deleteCustomization — name: \(category.name), docId: \(customID)")

        do {
            try await db.collection("customizations").document(customID).delete()
            AppLog.menu.debug("✅ deleteCustomization — deleted: \(category.name)")
            fetchCustomizations()
        } catch {
            AppLog.menu.error("❌ deleteCustomization — failed for \(category.name): \(error.localizedDescription)")
            AlertManager.shared.showError(title: "Failed to delete customization", message: error.localizedDescription)
        }
    }
}

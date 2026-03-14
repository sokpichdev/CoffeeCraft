//
//  ProductPickerSheet.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 3/14/26.
//
import SwiftUI

struct ProductPickerSheet: View {

    let options: [ProductOption]
    @Binding var selectedId: String?
    let onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // "All Products" row — only relevant in queue filter context
                // (analytics always needs a specific product, but harmless to include)
                Button {
                    selectedId = nil
                    onSelect()
                    dismiss()
                } label: {
                    HStack {
                        Label("All Products", systemImage: "square.stack.fill")
                            .foregroundStyle(Color.textPrimary)
                        Spacer()
                        if selectedId == nil {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.accentPrimary)
                        }
                    }
                }
                .listRowBackground(Color.surfacePrimary)

                Section {
                    ForEach(options) { option in
                        Button {
                            selectedId = option.id
                            onSelect()
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                // Avatar initials circle
                                ZStack {
                                    Circle()
                                        .fill(Color.accentPrimary.opacity(0.10))
                                        .frame(width: 34, height: 34)
                                    Text(String(option.name.prefix(1)).uppercased())
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.accentPrimary)
                                }

                                Text(option.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                if selectedId == option.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.accentPrimary)
                                }
                            }
                        }
                        .listRowBackground(Color.surfacePrimary)
                    }
                } header: {
                    Text("Products")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textMuted)
                        .textCase(nil)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationTitle("Select Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentPrimary)
                }
            }
        }
    }
}

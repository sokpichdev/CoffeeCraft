//
//  PickerSheetView.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/19/26.
//
import SwiftUI

struct PickerSheetView: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        CustomNavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            selectedOption = option
                            dismiss()
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if selectedOption == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.headline)
                                        .foregroundColor(Color.brown)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .customNavigationBar(title) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brown)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

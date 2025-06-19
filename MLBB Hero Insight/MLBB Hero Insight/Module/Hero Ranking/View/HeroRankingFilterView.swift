//
//  HeroRankingFilterView.swift
//  MLBB Hero Insight
//
//  Created by Sok Pich on 6/19/25.
//
import SwiftUI

struct HeroRankingFilterView: View {
    @Binding var day: Int
    @Binding var rank: String
    @Binding var size: String
    @Binding var index: String
    @Binding var sortField: String
    @Binding var sortOrder: String

    var onApply: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Day")) {
                    Picker("Day", selection: $day) {
                        ForEach([1, 3, 7, 15, 30], id: \.self) {
                            Text("\($0)").tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Rank")) {
                    Picker("Rank", selection: $rank) {
                        ForEach(["all", "epic", "legend", "mythic", "honor", "glory"], id: \.self) {
                            Text($0.capitalized).tag($0)
                        }
                    }
                }

                Section(header: Text("Size & Index")) {
                    TextField("Size", text: $size)
                        .keyboardType(.numberPad)

                    TextField("Index", text: $index)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Sorting")) {
                    Picker("Sort Field", selection: $sortField) {
                        ForEach(["win_rate", "pick_rate", "ban_rate"], id: \.self) {
                            Text($0.replacingOccurrences(of: "_", with: " ").capitalized).tag($0)
                        }
                    }

                    Picker("Sort Order", selection: $sortOrder) {
                        ForEach(["asc", "desc"], id: \.self) {
                            Text($0.uppercased()).tag($0)
                        }
                    }
                }
            }

            .navigationTitle("Filter Rankings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                    }
                }
            }
        }
    }
}

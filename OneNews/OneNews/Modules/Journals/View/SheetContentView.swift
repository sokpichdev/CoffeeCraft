//
//  SheetContentView.swift
//  OneNews
//
//  Created by Sok Pich on 12/5/24.
//

import SwiftUI

struct SheetContentView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var issueListVM: IssueListViewModel
    @Binding var selectedIndex: Int
    
    @State private var tempSelectedYear: String = ""
    @State private var tempSelectedIndex: Int = -1
    
    var defaultYear: String
    var defaultIssue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            headerView() // Header
                .padding(16)
            
            yearSelectionView() // Year Selection
//                .frame(height: 80)
            
            // Issues Grid
            IssueGridView(
                issueListVM: issueListVM,
                selectedYear: tempSelectedYear,
                tempSelectedIndex: $tempSelectedIndex
            )
        }
        .onAppear {
            tempSelectedYear = defaultYear
            tempSelectedIndex = -1
        }
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Text("Choose the issue")
                .font(.headline)
                .fontWeight(.medium)
            Spacer()
            Button(action: {
                applyChanges()
            }) {
                Text("Apply")
                    .foregroundColor(tempSelectedIndex >= 0 ? .white : .letters)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .background(tempSelectedIndex >= 0 ? Color.main : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(tempSelectedIndex >= 0 ? Color.main : Color.gray, lineWidth: 1)
            )
            .cornerRadius(50)
        }
    }
    
    @ViewBuilder
    private func yearSelectionView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(issueListVM.issueList, id: \.issueYear) { issueModel in
                    Button(action: {
                        tempSelectedYear = issueModel.issueYear ?? ""
                        tempSelectedIndex = -1 // Reset temporary index
                    }) {
                        VStack {
                            Text(issueModel.issueYear ?? "-")
                                .fontWeight(.medium)
                                .foregroundStyle(tempSelectedYear == issueModel.issueYear ? Color.main : .letters)
                            Text("\(issueModel.issueList?.count ?? 0)") // Total issues count
                                .fontWeight(.light)
                                .foregroundStyle(Color.letters.opacity(0.5))
                        }
                        .frame(width: 100, height: 60)
                        .background(Color.optionBtn1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(tempSelectedYear == issueModel.issueYear ? .main : Color.clear, lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 16)
        }    }
    
    private func applyChanges() {
        if tempSelectedIndex >= 0 { // Finalize selection only when Apply is clicked
            selectedIndex = tempSelectedIndex
            print("Applied Year: \(tempSelectedYear), Index: \(selectedIndex)")
            dismiss()
        }
    }
}

struct IssueGridView: View {
    @ObservedObject var issueListVM: IssueListViewModel
    var selectedYear: String
    @Binding var tempSelectedIndex: Int
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                if let issues = issueListVM.issueList.first(where: { $0.issueYear == selectedYear })?.issueList {
                    ForEach(issues.indices, id: \.self) { index in
                        Button(action: {
                            tempSelectedIndex = index
                        }) {
                            Text("Issue \(issues[index])")
                                .font(.caption)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Color.optionBtn1)
                                .cornerRadius(10)
                                .foregroundStyle(.letters)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(tempSelectedIndex == index ? Color.main : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                } else {
                    Text("NO ISSUES AVAILABLE")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        }
        .padding(10)
        .background(Color.background.opacity(0.8))
        .cornerRadius(5)
        .padding(16)
        
    }
}

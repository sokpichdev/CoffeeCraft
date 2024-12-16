//
//  SheetContentView.swift
//  OneNews
//
//  Created by Sok Pich on 12/5/24.
//

import SwiftUI

struct SheetContentView: View {
    @State var selectedYear: Int = 0
    @State var selectedIssue: Int = 0
    @State var isIssueSelected: Bool = false
    
    let yearArray: [[Int]] = [
        Array(1...100),  // Represents year 2024 with numbers 1 to 100
        Array(1...145),  // 2023
        Array(1...21),   // 2022
        Array(1...456),  // 2021
        Array(1...345)   // 2020
    ]
    
    private var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Choose the issue")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                // Apply button
                Button(action: {
                    // Perform apply action
                }) {
                    Text("Apply")
                        .foregroundColor(isIssueSelected ? .white : .letters)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .background(isIssueSelected ? Color.main : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isIssueSelected ? .main : Color.letters.opacity(0.4), lineWidth: 1)
                )
                .cornerRadius(10)
            }
            .padding(16)
            
            // Year selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(yearArray.indices, id: \.self) { yearIndex in
                        Button(action: {
                            print("Year \(2024 - yearIndex)") // Print year based on index
                            selectedYear = yearIndex
                        }) {
                            VStack(spacing: 5) {
                                Text("\(2024 - yearIndex)")
                                Text("\(yearArray[yearIndex].count)")
                                    .font(.caption)
                                    .fontWeight(.ultraLight)
                            }
                            .padding()
                            .frame(width: 100, height: 60)
                            .background(Color.optionBtn1)

                            .foregroundStyle(.letters)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedYear == yearIndex ? .main : Color.clear, lineWidth: 2)

                            )
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .frame(height: 80)
            
            // LazyVGrid for issues
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(yearArray[selectedYear].indices, id: \.self) { issueIndex in
                            Button(action: {
                                print("Issue \(issueIndex + 1)")
                                isIssueSelected = true
                                selectedIssue = issueIndex
                            }) {
                                Text("Issue \(issueIndex + 1)")
                                    .font(.caption2)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(.optionBtn1)
                            }
                            .foregroundStyle(.letters)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedIssue == issueIndex ? Color.main : Color.clear, lineWidth: 2)
                            )
                            .cornerRadius(10)
                            .id(0)
                        }
                    }
                }
                .onChange(of: selectedYear) { _ in
                    withAnimation {
                        proxy.scrollTo(0)
                    }
                    
                }
            }
            .padding(16)
        }
    }
}

#Preview { SheetContentView() }

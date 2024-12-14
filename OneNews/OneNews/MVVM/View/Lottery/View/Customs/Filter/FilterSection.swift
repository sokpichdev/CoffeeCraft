//
//  FilterSection.swift
//  OneNews
//
//  Created by Sok Pich on 12/13/24.
//

import SwiftUI

struct FilterSection: View {
    var countryName: String
    var numberOfResults: Int = 0
    @State private var isTicked: Bool = false
    @State private var isShow: Bool = false

    // Example row data
    @State private var rowData: [RowItem] = [
        RowItem(imageName: "result", title: "Good 4D", isChecked: false),
        RowItem(imageName: "result", title: "Good 4D", isChecked: true),
        RowItem(imageName: "result", title: "Good 4D", isChecked: false)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack {
                CountryCircle(countryName: countryName)

                Text("\(countryName) (\(numberOfResults))")
                    .foregroundColor(.letters)

                Spacer()

                // Tick btn
                Button(action: {
                    isTicked.toggle()
                    // Tick or untick all rows
                    for i in rowData.indices {
                        rowData[i].isChecked = isTicked
                    }
                }) {
                    CusImage(ImageName: isTicked ? "checkmark" : "")
                        .background(Color.softPink)
                        .foregroundStyle(Color.main)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.main, lineWidth: 1)
                        )
                }

                // Expand/Collapse Button
                Button(action: {
                    isShow.toggle()
                }) {
                    CusImage(ImageName: isShow ? "chevron.down" : "chevron.up")
                        .background(Color.softPink)
                        .foregroundStyle(Color.main)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.main, lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(Color.softPink)
            .frame(maxWidth: .infinity)
            Divider()/*.frame(height: 1).background(Color.black.opacity(0.3))*/

            // Additional rows
            if isShow {
                ForEach(rowData.indices, id: \.self) { index in
                    HStack {
                        Image(rowData[index].imageName)
                            .resizable()
                            .frame(width: 30, height: 30)

                        Text(rowData[index].title)
                            .foregroundColor(.letters)

                        Spacer()

                        Button(action: {
                            rowData[index].isChecked.toggle()
                        }) {
                            CusImage(ImageName: rowData[index].isChecked ? "checkmark" : "")
                                .background(Color.optionBtn2)
                                .foregroundStyle(Color.letters.opacity(0.7))
                                
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.letters.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .background(Color.optionBtn2)
                    Divider()/*.frame(height: 1).background(Color.black.opacity(0.1))*/
                }
                .transition(.slide)
            }
        }
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
//        .padding(.horizontal, 16)
        
        .shadow(radius: 3)
    }
}

// Example row data model
struct RowItem {
    var imageName: String
    var title: String
    var isChecked: Bool
}

struct CusImage: View {
    var ImageName: String
    var body: some View {
        Image(systemName: ImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding(6)
            .cornerRadius(4)
    }
}
#Preview {
    FilterSection(countryName: "Cambodia", numberOfResults: 3)
}

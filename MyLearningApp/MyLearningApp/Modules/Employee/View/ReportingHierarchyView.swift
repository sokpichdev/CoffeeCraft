//
//  ReportingHierarchyView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/20/25.
//
import SwiftUI

struct Employee: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let profileImage: String? // Image name
    let badge: String?
    let badgeColor: Color
    let borderColor: Color
    let backgroundColor: Color
    let textColor: Color
    let children: [Employee]
}

struct ReportingHierarchyView: View {
    let hierarchy = Employee(
        name: "Jerry",
        role: "Head of Operation -I",
        profileImage: nil,
        badge: "Inline Manager",
        badgeColor: Color.blue.opacity(0.2),
        borderColor: Color.red,
        backgroundColor: Color.white,
        textColor: Color.black,
        children: [
            Employee(
                name: "Atul Priy",
                role: "Head of Operation -II",
                profileImage: "atul",
                badge: "Immediate Supervisor",
                badgeColor: Color.orange.opacity(0.2),
                borderColor: Color.red,
                backgroundColor: Color.white,
                textColor: Color.black,
                children: [
                    Employee(
                        name: "Rakesh Dutt Pant",
                        role: "Team Lead UX UI",
                        profileImage: nil,
                        badge: nil,
                        badgeColor: Color.clear,
                        borderColor: Color.blue,
                        backgroundColor: Color.blue.opacity(0.2),
                        textColor: Color.white,
                        children: [
                            Employee(
                                name: "Hong",
                                role: "Senior UX UI Designer",
                                profileImage: "hong",
                                badge: nil,
                                badgeColor: Color.clear,
                                borderColor: Color.green,
                                backgroundColor: Color.white,
                                textColor: Color.black,
                                children: []
                            ),
                            Employee(
                                name: "Pink",
                                role: "Senior Graphic Designer",
                                profileImage: "pink",
                                badge: nil,
                                badgeColor: Color.clear,
                                borderColor: Color.green,
                                backgroundColor: Color.white,
                                textColor: Color.black,
                                children: []
                            ),
                            Employee(
                                name: "Kunthea",
                                role: "UX UI Designer",
                                profileImage: nil,
                                badge: nil,
                                badgeColor: Color.clear,
                                borderColor: Color.green,
                                backgroundColor: Color.white,
                                textColor: Color.black,
                                children: []
                            )
                        ]
                    )
                ]
            )
        ]
    )

    var body: some View {
        VStack(spacing: 20) {
            Text("Reporting Hierarchy")
                .font(.title2)
                .bold()
            
            HierarchyView(employee: hierarchy)
        }
        .padding()
    }
}

struct HierarchyView: View {
    let employee: Employee
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            EmployeeCard(employee: employee)
            
            if !employee.children.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    // Vertical Connector from parent to children
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 2, height: 20)
                        .offset(x: 20) // Adjust to align with the card

                    ForEach(employee.children) { child in
                        HStack(alignment: .top, spacing: 20) {
                            // Horizontal Connector
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 2)
                                .offset(y: 10) // Adjust to align with the card

                            HierarchyView(employee: child)
                        }
                    }
                }
                .padding(.leading, 40) // Indent children for hierarchy
            }
        }
    }
}

// MARK: - Employee Card
struct EmployeeCard: View {
    let employee: Employee
    
    var body: some View {
        HStack {
            if let image = employee.profileImage {
                Image(image)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                    .overlay(
                        Text(employee.name.prefix(2))
                            .foregroundColor(.white)
                            .bold()
                    )
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(employee.name)
                        .font(.headline)
                        .foregroundColor(employee.textColor)
                    
                    if let badge = employee.badge {
                        Text(badge)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(employee.badgeColor)
                            .cornerRadius(10)
                    }
                }
                Text(employee.role)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(employee.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(employee.borderColor, lineWidth: 2)
        )
        .cornerRadius(10)
    }
}

// MARK: - Preview
struct ReportingHierarchyView_Previews: PreviewProvider {
    static var previews: some View {
        ReportingHierarchyView()
    }
}

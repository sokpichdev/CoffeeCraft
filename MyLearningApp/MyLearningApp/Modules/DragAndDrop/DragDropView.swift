//
//  DragDropView.swift
//  MyLearningApp
//
//  Created by Sok Pich on 2/17/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Algorithms

struct DragDropView: View {
    @State private var toDoTasks: [DeveloperTask] = [MockData.taskOne, MockData.taskTwo, MockData.taskThree, MockData.taskFour, MockData.taskFive, MockData.taskSix]
    @State private var inProgressTasks: [DeveloperTask] = []
    @State private var doneTasks: [DeveloperTask] = []
    
    @State private var isToDoTargeted = false
    @State private var isInProgressTargeted = false
    @State private var isDoneTargeted = false
    var body: some View {
        ScrollView {
            HStack(spacing: 12) {
                KanbanView(title: "To Do", task: toDoTasks, isTargeted: isToDoTargeted)
                    .dropDestination(for: DeveloperTask.self) { droppedTasks, location in
                        for task in droppedTasks {
                            inProgressTasks.removeAll { $0.id == task.id }
                            doneTasks.removeAll { $0.id == task.id }
                        }
                        let totalTasks = toDoTasks + droppedTasks
                        toDoTasks = Array(totalTasks.uniqued())
                        return true
                    } isTargeted: { isTargeted in
                        isToDoTargeted = isTargeted
                    }
                
                KanbanView(title: "In Progress", task: inProgressTasks, isTargeted: isToDoTargeted)
                    .dropDestination(for: DeveloperTask.self) { droppedTasks, location in
                        for task in droppedTasks {
                            toDoTasks.removeAll { $0.id == task.id }
                            doneTasks.removeAll { $0.id == task.id }
                        }
                        let totalTasks = inProgressTasks + droppedTasks
                        inProgressTasks = Array(totalTasks.uniqued())
                        return true
                    } isTargeted: { isTargeted in
                        isInProgressTargeted = isTargeted
                    }
                
                KanbanView(title: "Done", task: doneTasks, isTargeted: isToDoTargeted)
                    .dropDestination(for: DeveloperTask.self) { droppedTasks, location in
                        for task in droppedTasks {
                            toDoTasks.removeAll { $0.id == task.id }
                            inProgressTasks.removeAll { $0.id == task.id }
                        }
                        let totalTasks = doneTasks + droppedTasks
                        doneTasks = Array(totalTasks.uniqued())
                        return true
                    } isTargeted: { isTargeted in
                        isDoneTargeted = isTargeted
                    }
            }
            .padding(16)
        }
    }
}

struct KanbanView: View {
    let title: String
    let task: [DeveloperTask]
    let isTargeted: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.footnote.bold())
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(isTargeted ? .teal.opacity(0.15): Color(.secondarySystemFill))
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(task, id: \.id) { task in
                        Text(task.title)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1, x: 1, y: 1)
                            .draggable(task)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

struct DeveloperTask: Codable, Hashable, Transferable {
    let id: UUID
    let title: String
    let owner: String
    let note: String
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .developerTask)
    }
}

extension UTType {
    static let developerTask = UTType(exportedAs: "com.example.developerTask")
}

struct MockData {
    static let taskOne = DeveloperTask(id: UUID(),
                                       title: "task 1",
                                       owner: "Nomery",
                                       note: "do it")
    static let taskTwo = DeveloperTask(id: UUID(),
                                       title: "task 2",
                                       owner: "Natsu",
                                       note: "do it")
    static let taskThree = DeveloperTask(id: UUID(),
                                       title: "task 3",
                                       owner: "Deadshot",
                                       note: "do it")
    static let taskFour = DeveloperTask(id: UUID(),
                                       title: "task 4",
                                       owner: "Deadshot",
                                       note: "do it")
    static let taskFive = DeveloperTask(id: UUID(),
                                       title: "task 5",
                                       owner: "Natsu",
                                       note: "do it")
    static let taskSix = DeveloperTask(id: UUID(),
                                       title: "task 6",
                                       owner: "Nomercy",
                                       note: "do it")
}

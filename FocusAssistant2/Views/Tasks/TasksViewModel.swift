//
//  TasksViewModel.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 21/09/2025.
//

import SwiftUI

struct TaskItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
}

@Observable
final class TasksViewModel {
    var tasks: [TaskItem] = [
        TaskItem(title: "Plan day"),
        TaskItem(title: "Deep work block"),
        TaskItem(title: "Break"),
        TaskItem(title: "Plan day"),
        TaskItem(title: "Deep work block"),
        TaskItem(title: "Break"),
        TaskItem(title: "Plan day"),
        TaskItem(title: "Deep work block"),
        TaskItem(title: "Break"),
        TaskItem(title: "Plan day"),
        TaskItem(title: "Deep work block"),
        TaskItem(title: "Break"),
        TaskItem(title: "Plan day"),
        TaskItem(title: "Deep work block"),
        TaskItem(title: "Break"),
    ]

    func addTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        tasks.append(TaskItem(title: title))
    }

    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    func toggle(_ task: TaskItem) {
        if let idx = tasks.firstIndex(of: task) {
            tasks[idx].isDone.toggle()
        }
    }
}


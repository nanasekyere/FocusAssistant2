import SwiftUI

struct TasksView: View {
    @State var viewModel: TasksViewModel
    @State private var newTaskTitle: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("New task", text: $newTaskTitle)
                        Button("Add") {
                            viewModel.addTask(title: newTaskTitle)
                            newTaskTitle = ""
                        }
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                Section("Tasks") {
                    ForEach(viewModel.tasks) { task in
                        HStack {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isDone ? .green : .secondary)
                                .onTapGesture { viewModel.toggle(task) }
                            Text(task.title)
                                .strikethrough(task.isDone)
                                .foregroundStyle(task.isDone ? .secondary : .primary)
                        }
                    }
                    .onDelete(perform: viewModel.delete)
                }
            }
            .navigationTitle("Tasks")
            .toolbar { EditButton() }
        }
    }
}

#Preview {
    TasksView(viewModel: TasksViewModel())
}

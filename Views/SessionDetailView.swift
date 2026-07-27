//
//  SessionDetailView.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  SessionDetailView.swift
//  FocusFlow
//

import SwiftUI

struct SessionDetailView: View {
    @EnvironmentObject var store: SessionStore
    @Environment(\.dismiss) private var dismiss

    let session: FocusSession
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false

    private var current: FocusSession {
        store.sessions.first { $0.id == session.id } ?? session
    }

    private var subject: Subject? {
        store.subject(for: current)
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    if let subject {
                        Label(subject.name, systemImage: "book.closed.fill")
                            .font(.subheadline)
                            .foregroundStyle(subject.color)
                    }
                    Text(current.task.isEmpty ? "Untitled session" : current.task)
                        .font(.title2).fontWeight(.semibold)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text(current.formattedActual)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("Time focused").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(current.plannedMinutes)m")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("Planned").font(.caption).foregroundStyle(.secondary)
                        }
                    }

                    if current.completed {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.subheadline).foregroundStyle(.green)
                    } else {
                        Label("Stopped early", systemImage: "stop.circle")
                            .font(.subheadline).foregroundStyle(.orange)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Date & Time") {
                Label(current.date.formatted(date: .long, time: .shortened),
                      systemImage: "calendar")
            }

            if !current.note.isEmpty {
                Section("Note") { Text(current.note) }
            }

            Section {
                Button { showingEdit = true } label: {
                    Label("Edit Session", systemImage: "pencil")
                }
                Button(role: .destructive) { showingDeleteAlert = true } label: {
                    Label("Delete Session", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            EditSessionView(session: current)
        }
        .alert("Delete this session?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                store.delete(current)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct EditSessionView: View {
    @EnvironmentObject var store: SessionStore
    @Environment(\.dismiss) private var dismiss

    let session: FocusSession
    @State private var task: String
    @State private var note: String
    @State private var selectedSubjectID: UUID
    @State private var validationError: String?

    init(session: FocusSession) {
        self.session = session
        _task = State(initialValue: session.task)
        _note = State(initialValue: session.note)
        _selectedSubjectID = State(initialValue: session.subjectID)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What did you work on?", text: $task)
                }
                Section("Subject") {
                    Picker("Subject", selection: $selectedSubjectID) {
                        ForEach(store.subjects) { subject in
                            Text(subject.name).tag(subject.id)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("Note") {
                    TextField("Add or edit your note…", text: $note, axis: .vertical)
                        .lineLimit(3...8)
                }
                if let error = validationError {
                    Section {
                        Text(error).foregroundStyle(.red).font(.footnote)
                    }
                }
            }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        guard !task.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationError = "Please enter a task description."
            return
        }
        var updated = session
        updated.task = task.trimmingCharacters(in: .whitespaces)
        updated.note = note
        updated.subjectID = selectedSubjectID
        store.update(updated)
        dismiss()
    }
}

extension FocusSession: Hashable {
    static func == (lhs: FocusSession, rhs: FocusSession) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

//
//  HistoryView.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  HistoryView.swift
//  FocusFlow
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: SessionStore
    @State private var searchText = ""
    @State private var selectedSubjectID: UUID? = nil

    private var filteredSessions: [FocusSession] {
        var list = store.sessions
        if let id = selectedSubjectID {
            list = list.filter { $0.subjectID == id }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.task.lowercased().contains(q) ||
                (store.subject(for: $0)?.name.lowercased().contains(q) ?? false) ||
                $0.note.lowercased().contains(q)
            }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: "All", isSelected: selectedSubjectID == nil) {
                            selectedSubjectID = nil
                        }
                        ForEach(store.subjects) { subject in
                            FilterChip(
                                label: subject.name,
                                color: subject.color,
                                isSelected: selectedSubjectID == subject.id
                            ) {
                                selectedSubjectID = selectedSubjectID == subject.id ? nil : subject.id
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))

                if filteredSessions.isEmpty {
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: searchText.isEmpty ? "No Sessions Yet" : "No Results",
                        message: searchText.isEmpty
                            ? "Complete a focus session and it will appear here."
                            : "Try a different search or filter."
                    )
                } else {
                    List {
                        ForEach(filteredSessions) { session in
                            NavigationLink(value: session) {
                                SessionRow(
                                    session: session,
                                    subject: store.subject(for: session)
                                )
                            }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets, in: filteredSessions)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search sessions…")
            .navigationDestination(for: FocusSession.self) { session in
                SessionDetailView(session: session)
            }
        }
    }
}

private struct FilterChip: View {
    let label: String
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline).fontWeight(.medium)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(isSelected ? color : Color(.secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

//
//  TimerView.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  TimerView.swift
//  FocusFlow
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var store: SessionStore
    @StateObject private var timer = TimerService()

    @State private var selectedSubjectID: UUID?
    @State private var task: String = ""
    @State private var plannedMinutes: Int = 25
    @State private var showingFinishSheet = false
    @State private var postNote: String = ""

    private var selectedSubject: Subject? {
        store.subjects.first { $0.id == selectedSubjectID }
    }

    private var ringColor: Color {
        selectedSubject?.color ?? .blue
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Timer ring
                    ZStack {
                        TimerRing(progress: timer.progress, color: ringColor)
                        VStack(spacing: 4) {
                            Text(timer.state == .idle ? formattedPlanned : timer.formattedRemaining)
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                            if timer.state != .idle {
                                Text(stateLabel)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 12)

                    if timer.state == .idle {
                        idleControls
                    } else {
                        activeControls
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("FocusFlow")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingFinishSheet) {
                finishSheet
            }
            .onChange(of: timer.state) { _, newState in
                if newState == .finished {
                    showingFinishSheet = true
                }
            }
        }
    }

    private var idleControls: some View {
        VStack(spacing: 16) {
            // Subject picker
            VStack(alignment: .leading, spacing: 8) {
                Label("Subject", systemImage: "book.closed.fill")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.subjects) { subject in
                            SubjectChip(
                                subject: subject,
                                isSelected: selectedSubjectID == subject.id
                            ) { selectedSubjectID = subject.id }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }

            // Task
            VStack(alignment: .leading, spacing: 8) {
                Label("What will you work on?", systemImage: "pencil")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(.secondary)
                TextField("e.g. Chapter 5 review, problem sets…", text: $task)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Duration
            VStack(alignment: .leading, spacing: 8) {
                Label("Duration: \(plannedMinutes) min", systemImage: "clock")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach([15, 25, 30, 45, 60], id: \.self) { mins in
                        Button {
                            plannedMinutes = mins
                        } label: {
                            Text("\(mins)m")
                                .font(.subheadline).fontWeight(.medium)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(plannedMinutes == mins ? ringColor : Color(.secondarySystemGroupedBackground))
                                .foregroundStyle(plannedMinutes == mins ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Start button
            Button {
                guard selectedSubjectID != nil else { return }
                timer.start(minutes: plannedMinutes)
            } label: {
                Text("Start Focusing")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedSubjectID == nil ? Color(.systemGray4) : ringColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(selectedSubjectID == nil)
        }
    }

    private var activeControls: some View {
        VStack(spacing: 16) {
            if let subject = selectedSubject {
                HStack(spacing: 8) {
                    Circle().fill(subject.color).frame(width: 8, height: 8)
                    Text(subject.name).font(.subheadline).fontWeight(.medium)
                    if !task.isEmpty {
                        Text("· \(task)").font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                Button {
                    if timer.state == .running { timer.pause() } else { timer.resume() }
                } label: {
                    Image(systemName: timer.state == .running ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .background(ringColor)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }

                Button {
                    saveSession(completed: false)
                    timer.reset()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .background(Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(.primary)
                        .clipShape(Circle())
                }
            }
            Text("Stop early to save partial progress")
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var finishSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("🎉").font(.system(size: 64))
                    Text("Session Complete!").font(.title2).fontWeight(.bold)
                    Text("You focused for \(plannedMinutes) minutes")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a note (optional)")
                        .font(.subheadline).fontWeight(.medium).foregroundStyle(.secondary)
                    TextField("How did it go?", text: $postNote, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Great work!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSession(completed: true)
                        timer.reset()
                        postNote = ""
                        showingFinishSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var formattedPlanned: String { String(format: "%02d:00", plannedMinutes) }
    private var stateLabel: String {
        switch timer.state {
        case .running: return "Focusing…"
        case .paused: return "Paused"
        case .finished: return "Done!"
        default: return ""
        }
    }

    private func saveSession(completed: Bool) {
        guard let subID = selectedSubjectID else { return }
        let session = FocusSession(
            subjectID: subID,
            task: task,
            plannedMinutes: plannedMinutes,
            actualSeconds: timer.elapsedSeconds,
            date: Date(),
            note: postNote,
            completed: completed
        )
        store.add(session)
    }
}

private struct SubjectChip: View {
    let subject: Subject
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(subject.name)
                .font(.subheadline).fontWeight(.medium)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(isSelected ? subject.color : Color(.secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? .clear : Color(.systemGray4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

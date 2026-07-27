//
//  SessionStore.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  SessionStore.swift
//  FocusFlow
//

import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {

    @Published private(set) var sessions: [FocusSession] = []
    @Published private(set) var subjects: [Subject] = Subject.defaults
    @Published var errorMessage: String?

    private let sessionsURL: URL
    private let subjectsURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        sessionsURL = docs.appendingPathComponent("sessions.json")
        subjectsURL = docs.appendingPathComponent("subjects.json")
        loadAll()
    }

    func add(_ session: FocusSession) {
        sessions.insert(session, at: 0)
        saveSessions()
    }

    func update(_ session: FocusSession) {
        guard let i = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[i] = session
        saveSessions()
    }

    func delete(_ session: FocusSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }

    func delete(at offsets: IndexSet, in list: [FocusSession]) {
        let ids = offsets.map { list[$0].id }
        sessions.removeAll { ids.contains($0.id) }
        saveSessions()
    }

    func subject(for session: FocusSession) -> Subject? {
        subjects.first { $0.id == session.subjectID }
    }

    func sessions(for subjectID: UUID?) -> [FocusSession] {
        guard let id = subjectID else { return sessions }
        return sessions.filter { $0.subjectID == id }
    }

    var totalSeconds: Int { sessions.reduce(0) { $0 + $1.actualSeconds } }
    var totalSessions: Int { sessions.count }
    var completedSessions: Int { sessions.filter { $0.completed }.count }

    var topSubject: Subject? {
        let grouped = Dictionary(grouping: sessions, by: \.subjectID)
        let totals = grouped.mapValues { $0.reduce(0) { $0 + $1.actualSeconds } }
        guard let best = totals.max(by: { $0.value < $1.value }) else { return nil }
        return subjects.first { $0.id == best.key }
    }

    var currentStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var check = cal.startOfDay(for: Date())
        let days = Set(sessions.map { cal.startOfDay(for: $0.date) })
        while days.contains(check) {
            streak += 1
            check = cal.date(byAdding: .day, value: -1, to: check)!
        }
        return streak
    }

    var averageSessionMinutes: Int {
        guard !sessions.isEmpty else { return 0 }
        return (totalSeconds / sessions.count) / 60
    }

    private func loadAll() {
        sessions = load(from: sessionsURL) ?? []
        subjects = load(from: subjectsURL) ?? Subject.defaults
    }

    private func load<T: Decodable>(from url: URL) -> T? {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        return value
    }

    private func saveSessions() { save(sessions, to: sessionsURL) }
    private func saveSubjects() { save(subjects, to: subjectsURL) }

    private func save<T: Encodable>(_ value: T, to url: URL) {
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }
    }
}

//
//  Models.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  Models.swift
//  FocusFlow
//

import Foundation
import SwiftUI

// MARK: - Subject

struct Subject: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    static let defaults: [Subject] = [
        Subject(name: "Math",       colorHex: "#FF6B6B"),
        Subject(name: "Science",    colorHex: "#4ECDC4"),
        Subject(name: "English",    colorHex: "#45B7D1"),
        Subject(name: "History",    colorHex: "#96CEB4"),
        Subject(name: "CS",         colorHex: "#FFEAA7"),
        Subject(name: "Other",      colorHex: "#DDA0DD"),
    ]
}

// MARK: - FocusSession

struct FocusSession: Identifiable, Codable {
    let id: UUID
    var subjectID: UUID
    var task: String
    var plannedMinutes: Int
    var actualSeconds: Int
    var date: Date
    var note: String
    var completed: Bool

    init(
        id: UUID = UUID(),
        subjectID: UUID,
        task: String,
        plannedMinutes: Int,
        actualSeconds: Int = 0,
        date: Date = Date(),
        note: String = "",
        completed: Bool = false
    ) {
        self.id = id
        self.subjectID = subjectID
        self.task = task
        self.plannedMinutes = plannedMinutes
        self.actualSeconds = actualSeconds
        self.date = date
        self.note = note
        self.completed = completed
    }

    var actualMinutes: Int { actualSeconds / 60 }
    var formattedActual: String {
        let m = actualSeconds / 60
        let s = actualSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Color hex extension

extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h = String(h.dropFirst()) }
        guard h.count == 6, let value = UInt64(h, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8)  & 0xFF) / 255
        let b = Double(value         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

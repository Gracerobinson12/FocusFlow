//
//  SessionRow.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  SessionRow.swift
//  FocusFlow
//

import SwiftUI

struct SessionRow: View {
    let session: FocusSession
    let subject: Subject?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(subject?.color ?? .gray)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.task.isEmpty ? "Untitled session" : session.task)
                    .font(.body)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(subject?.name ?? "Unknown")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text(session.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(session.formattedActual)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()
                if session.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

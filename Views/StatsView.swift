//
//  StatsView.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  StatsView.swift
//  FocusFlow
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: SessionStore

    private var totalHours: String {
        let h = store.totalSeconds / 3600
        let m = (store.totalSeconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if store.sessions.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.xaxis",
                        title: "No Data Yet",
                        message: "Complete focus sessions to see your statistics here."
                    )
                    .frame(minHeight: 400)
                } else {
                    VStack(spacing: 20) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(icon: "clock.fill", title: "Total Focus Time", value: totalHours, color: .blue)
                            StatCard(icon: "flame.fill", title: "Day Streak", value: "\(store.currentStreak)", color: .orange)
                            StatCard(icon: "checkmark.circle.fill", title: "Sessions Done", value: "\(store.totalSessions)", color: .green)
                            StatCard(icon: "timer", title: "Avg Session", value: "\(store.averageSessionMinutes)m", color: .purple)
                        }

                        if let top = store.topSubject {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Top Subject").font(.caption).foregroundStyle(.secondary)
                                    Text(top.name).font(.title2).fontWeight(.bold)
                                }
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundStyle(top.color)
                                    .font(.largeTitle)
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Focus by Subject").font(.headline).padding(.horizontal, 4)
                            ForEach(subjectTotals, id: \.subject.id) { item in
                                SubjectBar(
                                    subject: item.subject,
                                    seconds: item.seconds,
                                    maxSeconds: subjectTotals.first?.seconds ?? 1
                                )
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completion Rate").font(.headline)
                            let rate = store.totalSessions > 0
                                ? Double(store.completedSessions) / Double(store.totalSessions) : 0
                            ProgressView(value: rate).tint(.green)
                            Text("\(store.completedSessions) of \(store.totalSessions) sessions completed")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Stats")
        }
    }

    private var subjectTotals: [(subject: Subject, seconds: Int)] {
        store.subjects.compactMap { subject in
            let secs = store.sessions
                .filter { $0.subjectID == subject.id }
                .reduce(0) { $0 + $1.actualSeconds }
            return secs > 0 ? (subject, secs) : nil
        }
        .sorted { $0.seconds > $1.seconds }
    }
}

private struct SubjectBar: View {
    let subject: Subject
    let seconds: Int
    let maxSeconds: Int

    private var ratio: Double {
        maxSeconds > 0 ? Double(seconds) / Double(maxSeconds) : 0
    }

    private var label: String {
        let m = seconds / 60
        let h = m / 60
        if h > 0 { return "\(h)h \(m % 60)m" }
        return "\(m)m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(subject.name).font(.subheadline)
                Spacer()
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(subject.color.opacity(0.2))
                        .frame(width: geo.size.width)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(subject.color)
                        .frame(width: geo.size.width * ratio)
                        .animation(.easeOut(duration: 0.6), value: ratio)
                }
            }
            .frame(height: 8)
        }
    }
}

//
//  TimerService.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  TimerService.swift
//  FocusFlow
//

import Foundation
import Combine

enum TimerState {
    case idle, running, paused, finished
}

@MainActor
final class TimerService: ObservableObject {

    @Published var state: TimerState = .idle
    @Published var secondsRemaining: Int = 0
    @Published var totalSeconds: Int = 0
    @Published var elapsedSeconds: Int = 0

    private var timer: AnyCancellable?

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(totalSeconds)
    }

    var formattedRemaining: String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    func start(minutes: Int) {
        let secs = minutes * 60
        totalSeconds = secs
        secondsRemaining = secs
        elapsedSeconds = 0
        state = .running
        tick()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        timer?.cancel()
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        tick()
    }

    func reset() {
        timer?.cancel()
        state = .idle
        secondsRemaining = 0
        elapsedSeconds = 0
        totalSeconds = 0
    }

    private func tick() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.secondsRemaining > 0 {
                    self.secondsRemaining -= 1
                    self.elapsedSeconds += 1
                } else {
                    self.timer?.cancel()
                    self.state = .finished
                }
            }
    }
}

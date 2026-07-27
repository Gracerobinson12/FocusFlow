//
//  TimerRing.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  TimerRing.swift
//  FocusFlow
//

import SwiftUI

struct TimerRing: View {
    var progress: Double
    var color: Color
    var lineWidth: CGFloat = 14
    var size: CGFloat = 260

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
        .frame(width: size, height: size)
    }
}

//
//  CountdownView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI

struct CountdownView: View {
    /// The current number on the countdown, in seconds
    @State var timeLeft: Int
    /// Called when the countdown completes
    var countdownComplete: () -> Void

    init(duration: Int, countdownComplete: @escaping () -> Void) {
        _timeLeft = .init(initialValue: duration)
        self.countdownComplete = countdownComplete
    }

    var body: some View {
        VStack {
            Text(timeLeft > 0 ? "\(timeLeft)" : "GO!")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .contentTransition(.numericText(value: Double(timeLeft)))
        }
        .onAppear {
            tickDown()
        }
    }

    func tickDown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            timeLeft -= 1

            if timeLeft > 0 {
                tickDown()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    countdownComplete()
                }
            }
        }
    }
}

#Preview {
    CountdownView(duration: 4, countdownComplete: {})
}

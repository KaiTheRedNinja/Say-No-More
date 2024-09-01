//
//  TimerView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI
import BezelKit

struct TimerView: View {
    var timerData: SNTimer
    var complete: () -> Void

    @State var elapsedTime: TimeInterval = 0

    private var timerPublisher = Timer.publish(every: 0.05, on: .main, in: .default).autoconnect()

    init(timerData: SNTimer, complete: @escaping () -> Void) {
        self.timerData = timerData
        self.complete = complete
    }

    var body: some View {
        timerIndicator(percentage: elapsedTime / timerData.duration)
            .onReceive(timerPublisher) { output in
                // timer must not be paused
                guard timerData.isPaused == false else { return }

                // elapsed time yay
                let elapsed = timerData.elapsedTime(from: output)

                guard elapsed < timerData.duration else {
                    self.elapsedTime = timerData.duration
                    complete()
                    return
                }

                self.elapsedTime = elapsed
            }
            .animation(.linear, value: elapsedTime)
    }

    @ViewBuilder
    func timerIndicator(percentage: CGFloat) -> some View {
        let lineWidth: CGFloat = 14

        GeometryReader { geom in
            ZStack {
                RoundedRectangle(cornerRadius: .deviceBezel - lineWidth/2)
                    .stroke(.gray.opacity(0.3), style: .init(lineWidth: lineWidth, lineJoin: .round))
                    .frame(width: geom.size.width, height: geom.size.height)

                RoundedRectangle(cornerRadius: .deviceBezel - lineWidth/2)
                    .trim(from: percentage, to: 1)
                    .stroke(
                        colorFor(percentage: percentage),
                        style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: geom.size.height, height: geom.size.width)
                    .rotationEffect(.degrees(-90))
                    .frame(width: geom.size.width, height: geom.size.height)
            }
        }
        .padding(lineWidth/2)
        .ignoresSafeArea()
    }

    func colorFor(percentage: CGFloat) -> Color {
        if percentage < 0.4 {
            .green
        } else if percentage < 0.7 {
            .yellow
        } else {
            .red
        }
    }
}

private struct TimerPreview: View {
    @State var timerData: SNTimer

    var body: some View {
        ZStack {
            TimerView(timerData: timerData) {
                print("Timer complete!")
            }

            if timerData.isPaused {
                Button("Start") {
                    timerData.start()
                }
            } else {
                Button("Pause") {
                    timerData.pause()
                }
            }
        }
    }
}

#Preview {
    TimerPreview(timerData: .init(duration: 10))
}

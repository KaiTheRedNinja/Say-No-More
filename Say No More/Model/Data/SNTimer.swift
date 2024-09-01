//
//  SNTimer.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import Foundation

/// An instance representing the data of the timer associated with a Taboo "turn". Does not actually contain a timer.
struct SNTimer {
    /// Whether or not the timer is paused
    private(set) var isPaused: Bool = true

    /// The total duration of the timer
    private(set) var duration: TimeInterval

    /// The effective start date, where `Date.now`'s time elapsed from ``effectiveStartDate`` is the timer's
    /// elapsed value
    ///
    /// May not be the actual date that the timer was started, due to pauses
    private var effectiveStartDate: Date?

    /// The date that the timer was paused
    private var pausedDate: Date?

    /// Creates an `SNTimer` that lasts a given duration
    init(duration: TimeInterval) {
        self.duration = duration
    }

    /// The elapsed time between a given date (defaults to `Date.now`) and a reference date, to provide an accurate
    /// measure of how much time has elapsed in the timer, taking pauses into account
    ///
    /// If ``isPaused`` is true, the value of `date` is ignored as the elapsed time when the timer is paused is the
    /// same regardless of the current time
    func elapsedTime(from date: Date = .now) -> TimeInterval {
        if isPaused {
            guard let pausedDate, let effectiveStartDate else { return 0 }
            return pausedDate.timeIntervalSince(effectiveStartDate)
        } else {
            guard let effectiveStartDate else { return 0 }
            return date.timeIntervalSince(effectiveStartDate)
        }
    }

    /// Starts or unpauses the timer at a given date (defaults to `Date.now`)
    mutating func start(at date: Date = .now) {
        guard isPaused else { return }

        // calculate the current elapsed time (defaults to zero when timer hasn't been started)
        let elapsed = elapsedTime(from: date)
        let newEffectiveStartDate = date.addingTimeInterval(-elapsed)
        effectiveStartDate = newEffectiveStartDate

        // mark the timer as unpaused
        isPaused = false
    }

    /// Pauses the timer at a given date (defaults to `Date.now`)
    mutating func pause(at date: Date = .now) {
        guard !isPaused else { return }

        isPaused = true
        pausedDate = date
    }
}

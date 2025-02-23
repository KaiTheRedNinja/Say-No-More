//
//  SNCardProvider.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

protocol SNCardProvider {
    /// Provides a card to the caller. This should draw from an internal first-in-last-out queue,
    /// where subsequent calls to this function yeild different results.
    ///
    /// This function should call (but not be suspended by) any functions to regenerate the internal queue.
    /// Return nil if the queue is empty and has not been replenished yet.
    func takeCard() -> SNCard?
}

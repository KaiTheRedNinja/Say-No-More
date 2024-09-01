//
//  SNTurn.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import Foundation

/// An instance representing a single Taboo "turn"
struct SNTurn: Codable, Identifiable, Equatable {
    var id: UUID = .init()

    /// The team that is playing the turn
    var team: SNTeam
    /// The cards the team won, where the first element is the first card won
    var wonCards: [SNCard]
    /// The cards the team forfeited, where the first element is the first card forfeited
    var forfeitedCards: [SNCard]
}

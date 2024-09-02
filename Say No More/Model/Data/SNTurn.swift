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

    /// The net gain of points
    var netPoints: Int { wonCards.count - forfeitedCards.count }
}

#if !DEBUG
@available(swift, obsoleted: 1.0)
#endif
extension SNTurn {
    init(team: SNTeam, won: Int, forfeit: Int) {
        self.init(
            team: team,
            wonCards: (0..<won).map { index in
                    .init(
                        word: "Won \(index)",
                        forbiddenWords: ["A", "B", "C", "D", "E"].map { "\($0)\(index)" }
                    )
            },
            forfeitedCards: (0..<forfeit).map { index in
                    .init(
                        word: "Forfeit \(index)",
                        forbiddenWords: ["V", "W", "X", "Y", "Z"].map { "\($0)\(index)" }
                    )
            }
        )
    }
}

//
//  SNGame.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import Foundation

/// An instance representing a Taboo "game", including teams, scores, and past cards
struct SNGame: Codable, Identifiable, Equatable {
    var id: UUID = .init()

    /// A catalogue of turns within the game, where the first element is the first turn
    var turns: [SNTurn]

    /// Gets the points for a team, based on the turns so far.
    ///
    /// For each turn, a won card is +1 point to the team playing the turn, a forfeited card is +1 point to
    /// the opposite team.
    func pointsFor(team: SNTeam, upToTurn: Int = -1) -> Int {
        let opponent = team.opponent()

        let turnsSample: [SNTurn]
        if upToTurn >= 0 {
            turnsSample = Array(turns.prefix(through: upToTurn))
        } else {
            turnsSample = turns
        }

        return turnsSample.reduce(0) { score, turn in
            switch turn.team {
            case team:
                return score + turn.wonCards.count
            case opponent:
                return score + turn.forfeitedCards.count
            default: fatalError() // does not occur
            }
        }
    }
}

//
//  SNTeam.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import Foundation

/// An instance representing a Taboo "team", of which there are only two
enum SNTeam: String, Codable, Identifiable {
    /// The first team, which plays the first turn
    case team1 = "Team 1"
    /// The second team, which plays the second turn
    case team2 = "Team 2"

    var id: String {
        rawValue
    }

    /// The opponent of this team
    func opponent() -> SNTeam {
        switch self {
        case .team1: return .team2
        case .team2: return .team1
        }
    }
}

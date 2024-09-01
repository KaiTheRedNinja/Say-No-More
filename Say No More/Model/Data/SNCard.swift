//
//  SNCard.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import Foundation

/// An instance representing a single Taboo "card"
struct SNCard: Codable, Identifiable, Equatable {
    var id: UUID = .init()

    var word: String = ""
    var forbiddenWords: [String] = []
}

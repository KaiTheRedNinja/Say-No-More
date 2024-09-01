//
//  SNTestingCardProvider.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import Foundation

private let testingCards: [SNCard] = [
    .init(
        word: "Lighthouse",
        forbiddenWords: [
            "Beacon",
            "Coastline",
            "Navigation",
            "Signal",
            "Tower"
        ]
    ),
    .init(
        word: "Violin",
        forbiddenWords: [
            "Bow",
            "Strings",
            "Orchestra",
            "Fretboard",
            "Melody"
        ]
    ),
    .init(
        word: "Oasis",
        forbiddenWords: [
            "Desert",
            "Water",
            "Palm trees",
            "Refuge",
            "Mirage"
        ]
    ),
    .init(
        word: "Monastery",
        forbiddenWords: [
            "Monk",
            "Cloister",
            "Meditation",
            "Silence",
            "Chapel"
        ]
    ),
    .init(
        word: "Kaleidoscope",
        forbiddenWords: [
            "Colors",
            "Patterns",
            "Reflection",
            "Symmetry",
            "Tube"
        ]
    )
]

class SNTestingCardProvider: SNCardProvider {
    var cards: [SNCard]

    init(cards: [SNCard] = testingCards) {
        self.cards = cards
    }

    func takeCard() -> SNCard? {
        print("Last card: \(cards.last)")
        return cards.popLast()
    }

    func putCard(_ card: SNCard) {
        cards.append(card)
    }
}

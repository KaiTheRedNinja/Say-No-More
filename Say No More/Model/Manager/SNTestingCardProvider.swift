//
//  SNTestingCardProvider.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

#if DEBUG

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

/// A card provider that uses a collection of testing cards
class SNTestingCardProvider: SNCardProvider {
    var cards: [SNCard]

    init(cards: [SNCard] = testingCards) {
        self.cards = cards
    }

    func takeCard() -> SNCard? {
        print("Last card: \(cards.last.debugDescription)")
        return cards.popLast()
    }
}
/// A card provider that creates cards via numeric sequences
class SNSequentialCardProvider: SNCardProvider {
    var index: Int

    init(index: Int = 0) {
        self.index = index
    }

    func takeCard() -> SNCard? {
        index += 1
        return .init(
            word: "Word \(index)",
            forbiddenWords: ["A", "B", "C", "D", "E"].map { "\($0)\(index)" }
        )
    }
}

#endif

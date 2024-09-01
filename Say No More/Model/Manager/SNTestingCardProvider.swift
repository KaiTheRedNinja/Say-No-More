//
//  SNTestingCardProvider.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import Foundation

class SNTestingCardProvider: SNCardProvider {
    var cards: [SNCard]

    init(cards: [SNCard]) {
        self.cards = cards
    }

    func takeCard() -> SNCard? {
        cards.popLast()
    }

    func putCard(_ card: SNCard) {
        cards.append(card)
    }
}

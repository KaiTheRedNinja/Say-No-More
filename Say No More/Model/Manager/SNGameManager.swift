//
//  SNGameManager.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import Foundation

/// Manages a Taboo game
@Observable
class SNGameManager {
    /// The card provider
    public var cardProvider: any SNCardProvider

    /// The game that this manager is managing
    private(set) var game: SNGame
    /// If a turn is currently happening, meaning the last turn in ``game``'s ``SNGame/turns`` is currently
    /// being played.
    private(set) var turnIsActive: Bool = false
    /// The current card. DO NOT assume that this value is populated at any point in time.
    private(set) var currentCard: SNCard?

    init(game: SNGame = .init(turns: []), cardProvider: any SNCardProvider) {
        self.cardProvider = cardProvider
        self.game = game
    }

    /// Starts the next turn
    func startNextTurn() {
        guard !turnIsActive else { return }

        // determine the new team
        let newTeam = game.turns.last?.team.opponent() ?? .team1
        let newTurn = SNTurn(
            team: newTeam,
            wonCards: [],
            forfeitedCards: []
        )

        regenerateCurrentCard()
        turnIsActive = true
        game.turns.append(newTurn)
    }

    /// Ends the current turn
    func endCurrentTurn() {
        guard turnIsActive else { return }
        turnIsActive = false

        currentCard = nil
    }

    /// Marks the current card as won
    func markCurrentCardAsWon() {
        guard turnIsActive,
              let currentCard,
              var currentTurn = game.turns.last
        else { return }

        // update the current turn
        currentTurn.wonCards.append(currentCard)
        game.turns[game.turns.count-1] = currentTurn

        // regenerate the current card
        regenerateCurrentCard()
    }

    /// Marks the current card as forfeit
    func markCurrentCardAsForfeited() {
        guard turnIsActive,
              let currentCard,
              var currentTurn = game.turns.last
        else { return }

        // update the current turn
        currentTurn.forfeitedCards.append(currentCard)
        game.turns[game.turns.count-1] = currentTurn

        // regenerate the current card
        regenerateCurrentCard()
    }

    /// Refreshes the current card. Does nothing if ``currentCard`` is not nil.
    func refreshCurrentCard() {
        guard !turnIsActive else { return }
        regenerateCurrentCard()
    }

    /// Regenerates the current card. Does not mark it as won/forfeited, and should only be called once actions on
    /// ``currentCard`` have been finished.
    private func regenerateCurrentCard() {
        currentCard = cardProvider.takeCard()
    }
}

private struct SNCardPlay: Identifiable {
    enum CardStatus: String {
        case won
        case forfeit
    }

    var card: SNCard
    var status: CardStatus

    var id: String {
        "\(card.id)_\(status)"
    }
}

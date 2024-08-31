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
    /// The game that this manager is managing
    private(set) var game: SNGame
    /// If a turn is currently happening, meaning the last turn in ``game``'s ``SNGame/turns`` is currently
    /// being played.
    private(set) var turnIsActive: Bool = false
    /// The current card. DO NOT assume that this value is populated at any point in time.
    private(set) var currentCard: SNCard?

    /// The undo record, where the last element is the most recent win/forfeit card action
    private var undoRecord: [SNCardPlay] = []

    init() {
        self.game = .init(turns: [])
    }

    /// Starts the next turn
    func startNextTurn() {
        guard !turnIsActive else { return }

        // determine the current team
        let currentTeam = game.turns.last?.team ?? .team1
        let newTurn = SNTurn(
            team: currentTeam,
            wonCards: [],
            forfeitedCards: []
        )

        regenerateCurrentCard()
        game.turns.append(newTurn)
        turnIsActive = true
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
        undoRecord.append(.init(card: currentCard, status: .won))

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
        undoRecord.append(.init(card: currentCard, status: .forfeit))

        // regenerate the current card
        regenerateCurrentCard()
    }

    /// Undoes the last win/forfeit action
    func undoLastAction() {
        guard turnIsActive,
              let lastAction = undoRecord.last,
              var currentTurn = game.turns.last
        else { return }

        // remove the card from where it went
        switch lastAction.status {
        case .won:
            currentTurn.wonCards.removeLast()
        case .forfeit:
            currentTurn.forfeitedCards.removeLast()
        }

        // update the current turn
        game.turns[game.turns.count-1] = currentTurn

        // put the card back into the "pile"
        putCardBackInPile(lastAction.card)
    }

    /// Regenerates the current card. Does not mark it as won/forfeited, and should only be called once actions on
    /// ``currentCard`` have been finished.
    private func regenerateCurrentCard() {
        guard turnIsActive else { return }
        currentCard = nil

        // TODO: regenerate current card
    }

    /// Puts a card back into the pile, such that the next card called by ``regenerateCurrentCard()`` is this one.
    ///
    /// Does not change the current card or the game state
    private func putCardBackInPile(_ card: SNCard) {
        guard turnIsActive else { return }

        // TODO: put card back into pile
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

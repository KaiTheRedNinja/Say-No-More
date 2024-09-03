//
//  GameView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI

struct GameView: View {
    @State var gameManager: SNGameManager
    @State var gameState: GameState = .countdown
    var archive: any ArchiveManager

    init(gameManager: SNGameManager, archive: any ArchiveManager) {
        self.gameManager = gameManager
        self.archive = archive
    }

    enum GameState {
        case countdown
        case turn
        case intermission
        case finish
    }

    var body: some View {
        ZStack {
            switch gameState {
            case .countdown:
                CountdownView(
                    duration: 3,
                    countdownComplete: {
                        gameState = .turn
                    }
                )
            case .turn:
                TurnView(
                    gameManager: gameManager,
                    turnComplete: {
                        gameManager.endCurrentTurn()
                        gameState = .intermission
                    }
                )
            case .intermission:
                IntermissionView(
                    gameManager: gameManager,
                    gameEnd: {
                        gameState = .finish
                    },
                    turnStart: {
                        gameManager.startNextTurn()
                        gameState = .countdown
                    }
                )
            case .finish:
                GameStatsView(game: gameManager.game, archive: archive)
            }
        }
        .animation(.default, value: gameManager.turnIsActive)
        .animation(.default, value: gameState)
        .onAppear {
            gameManager.startNextTurn()
            gameState = .countdown
        }
    }
}

#Preview {
    GameView(
        gameManager: .init(cardProvider: SNSequentialCardProvider()),
        archive: SNArchiveMockManager.shared
    )
}

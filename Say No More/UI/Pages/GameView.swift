//
//  GameView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI

struct GameView: View {
    @State var gameManager: SNGameManager

    @State var showCountdown: Bool = false

    var body: some View {
        ZStack {
            if gameManager.turnIsActive {
                if showCountdown {
                    CountdownView(
                        duration: 3,
                        countdownComplete: {
                            showCountdown = false
                        }
                    )
                } else {
                    TurnView(
                        gameManager: gameManager,
                        turnComplete: {
                            gameManager.endCurrentTurn()
                        }
                    )
                }
            } else {
                IntermissionView(
                    gameManager: gameManager,
                    turnStart: {
                        showCountdown = true
                        gameManager.startNextTurn()
                    }
                )
            }
        }
        .animation(.default, value: gameManager.turnIsActive)
        .animation(.default, value: showCountdown)
        .onAppear {
            showCountdown = true
            gameManager.startNextTurn()
        }
    }
}

#Preview {
    GameView(gameManager: .init(cardProvider: SNSequentialCardProvider()))
}

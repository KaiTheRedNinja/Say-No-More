//
//  GameView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI

struct GameView: View {
    @State var gameManager: SNGameManager

    var body: some View {
        ZStack {
            if gameManager.turnIsActive {
                TurnView(
                    gameManager: gameManager,
                    turnComplete: {
                        gameManager.endCurrentTurn()
                    }
                )
            } else {
                IntermissionView(
                    gameManager: gameManager,
                    turnStart: {
                        gameManager.startNextTurn()
                    }
                )
            }
        }
        .animation(.default, value: gameManager.turnIsActive)
        .onAppear {
            gameManager.startNextTurn()
        }
    }
}

#Preview {
    GameView(gameManager: .init(cardProvider: SNTestingCardProvider()))
}

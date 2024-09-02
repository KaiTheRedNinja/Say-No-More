//
//  GameView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI
import BezelKit

/// The view associated with a turn.
///
/// This view also controls starting and ending the timer, and will automatically start the turn's timer when this view
/// appears. It assumes that the game manager's turn has already started.
///
/// Note that `TurnView`does not end the turn when ``turnComplete`` is called. It is up to the implementation
/// of ``turnComplete`` to do that.
struct TurnView: View {
    @State var gameManager: SNGameManager
    @State private var timerData: SNTimer
    @State private var cards: [DraggableCardData] = []

    @Environment(\.dismiss)
    var dismiss

    var turnComplete: () -> Void

    init(
        gameManager: SNGameManager,
        timerData: SNTimer = .init(duration: 60),
        turnComplete: @escaping () -> Void
    ) {
        self.gameManager = gameManager
        self.turnComplete = turnComplete
        self.timerData = timerData
    }

    var body: some View {
        ZStack {
            TimerView(timerData: timerData, complete: {
                turnComplete()
            })

            GeometryReader { geom in
                ZStack {
                    Color.clear
                        .onChange(of: gameManager.currentCard) { _, _ in
                            if let currentCard = gameManager.currentCard {
                                cards.append(.init(card: currentCard))
                            }
                        }
                    ForEach(cards.reversed(), id: \.card.id) { card in
                        DraggableCardView(
                            data: card,
                            screenRect: geom.frame(in: .global),
                            markWon: {
                                gameManager.markCurrentCardAsWon()
                            },
                            markForfeit: {
                                gameManager.markCurrentCardAsForfeited()
                            },
                            animationComplete: {
                                // removes this card
                                cards.removeAll(where: { $0.card.id == card.card.id })
                            }
                        )
                        .id(card.card.id)
                    }
                }
            }

            buttonsView
        }
        .ignoresSafeArea()
        .onAppear {
            if let currentCard = gameManager.currentCard {
                cards.append(.init(card: currentCard))
            }
            timerData.start()
        }
    }

    var buttonsView: some View {
        VStack {
            HStack {
                Button {
                    turnComplete()
                } label: {
                    ZStack {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.black)
                            .padding(4)
                    }
                    .frame(width: 40, height: 40)
                }

                Spacer()

                Button {
                    if timerData.isPaused {
                        timerData.start()
                    } else {
                        timerData.pause()
                    }
                } label: {
                    ZStack {
                        Image(systemName: timerData.isPaused ? "play" : "pause")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.primary)
                            .padding(4)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .frame(width: 40, height: 40)
                }
            }
            .padding([.horizontal, .top], .deviceBezel - 20)

            Spacer()

            HStack {
                Button {
                    cards.last?.state = .won
                } label: {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.background)
                            .shadow(color: .green, radius: 5)
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.green)
                    }
                    .frame(width: 60, height: 60)
                }
                .symbolEffect(.bounce, value: gameManager.game.turns.last?.wonCards)

                Spacer()

                Button {
                    cards.last?.state = .forfeit
                } label: {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.background)
                            .shadow(color: .red, radius: 5)
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.red)
                    }
                    .frame(width: 60, height: 60)
                }
                .symbolEffect(.bounce, value: gameManager.game.turns.last?.forfeitedCards)
            }
            .padding([.horizontal, .bottom], .deviceBezel - 30)
        }
        .buttonStyle(.plain)
    }
}

private struct TurnPreview: View {
    @State var gameManager: SNGameManager = .init(cardProvider: SNSequentialCardProvider())

    var body: some View {
        TurnView(
            gameManager: gameManager,
            turnComplete: {}
        )
        .onAppear {
            gameManager.startNextTurn()
        }
    }
}

#Preview {
    TurnPreview()
}

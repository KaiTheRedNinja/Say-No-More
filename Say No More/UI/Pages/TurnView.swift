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
struct TurnView: View {
    @State var gameManager: SNGameManager
    @State private var timerData: SNTimer

    @State private var screenRect: CGRect = .zero
    @State private var dragTranslation: CGSize = .zero
    @State private var cardScale: CGFloat = 1

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

                    if let currentCard = gameManager.currentCard {
                        draggableCard(currentCard)
                            .frame(
                                width: geom.size.width * 0.6,
                                height: geom.size.height * 0.6
                            )
                    }
                }
                .onAppear {
                    self.screenRect = geom.frame(in: .global)
                }
                .onChange(of: geom.frame(in: .global)) { _, _ in
                    self.screenRect = geom.frame(in: .global)
                }
            }

            buttonsView
        }
        .ignoresSafeArea()
        .onAppear {
            timerData.start()
        }
    }

    func draggableCard(_ card: SNCard) -> some View {
        CardView(card: card)
            .scaleEffect(cardScale)
            .offset(dragTranslation)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        withAnimation(.interactiveSpring) {
                            dragTranslation = .init(
                                width: value.translation.width * 1.1,
                                height: value.translation.height * 1.1
                            )
                        }
                    }
                    .onEnded { value in
                        decideCardFinalLocation(endLocation: value.predictedEndLocation)
                    }
            )
    }

    var buttonsView: some View {
        VStack {
            HStack {
                Button {
                    // TODO: exit
                } label: {
                    ZStack {
                        // we use this to get the nice drop shadow for the checkmark, so that
                        // it doesn't intersect the tick
                        Image(systemName: "chevron.left")
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
                        // we use this to get the nice drop shadow for the checkmark, so that
                        // it doesn't intersect the tick
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
                    sendCard(won: true)
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
                    sendCard(won: false)
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

    func decideCardFinalLocation(endLocation: CGPoint) {
        // determine if the projected end location is in the bottom third of the screen,
        // and either the left or right third of the screen
        guard endLocation.y > screenRect.height * 0.66,
              endLocation.x < screenRect.width * 0.33 ||
                endLocation.x > screenRect.width * 0.66
        else {
            // if its not, return it to the center of the screen
            withAnimation(.spring) {
                dragTranslation = .zero
            }

            return
        }

        // determine where to "send" the card
        let won = endLocation.x < screenRect.width * 0.33

        sendCard(won: won)
    }

    func sendCard(won: Bool) {
        // send it to the correct corner
        let location: CGPoint = if won {
            CGPoint(x: screenRect.minX + 50, y: screenRect.maxY - 50)
        } else {
            CGPoint(x: screenRect.maxX - 50, y: screenRect.maxY - 50)
        }

        // mark it as either won or forfeit
        if won {
            gameManager.markCurrentCardAsWon()
        } else {
            gameManager.markCurrentCardAsForfeited()
        }

        // convert it to an ofset
        let center = CGPoint(x: screenRect.midX, y: screenRect.midY)
        let offset = CGSize(
            width: location.x - center.x,
            height: location.y - center.y
        )

        withAnimation(.spring) {
            dragTranslation = offset
            cardScale = 0.1
        } completion: {
            dragTranslation = .zero
            cardScale = 1
        }
    }
}

private struct TurnPreview: View {
    @State var gameManager: SNGameManager = .init(cardProvider: SNTestingCardProvider())

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

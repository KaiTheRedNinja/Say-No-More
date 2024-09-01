//
//  IntermissionView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI

/// The view shown in between different turns.
///
/// Note that `IntermissionView`does not end the turn when ``turnStart`` is called. It is up to the implementation
/// of ``turnStart`` to do that.
struct IntermissionView: View {
    @State var gameManager: SNGameManager

    @Environment(\.dismiss)
    var dismiss

    var turnStart: () -> Void

    init(gameManager: SNGameManager, turnStart: @escaping () -> Void) {
        self.gameManager = gameManager
        self.turnStart = turnStart
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .center) {
                    Text("Times Up!")
                        .font(.largeTitle)
                        .bold()

                    Image(systemName: "clock.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .symbolEffect(.bounce, options: .nonRepeating)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if let turn = gameManager.game.turns.last {
                Section("Turn Scores") {
                    HStack {
                        VStack(spacing: 15) {
                            Text("\(turn.wonCards.count)")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                                .shadow(color: .green, radius: 2)

                            Text("Guessed")
                                .font(.title3)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .padding(.horizontal, 8)

                        VStack(spacing: 15) {
                            Text("\(turn.forfeitedCards.count)")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .foregroundStyle(.red)
                                .shadow(color: .red, radius: 2)

                            Text("Forfeited")
                                .font(.title3)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.bottom, 10)
                    .listRowBackground(Color(uiColor: .systemGroupedBackground))
                }
            }

            Section { // next turn buttons
                HStack {
                    Button {
                        dismiss.callAsFunction()
                    } label: {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.6))
                            .overlay {
                                Text("Finish\nGame")
                                    .font(.title3)
                                    .bold()
                            }
                    }
                    .buttonStyle(.plain)
                    .containerRelativeFrame(.horizontal, count: 3, spacing: 0)

                    Button {
                        turnStart()
                    } label: {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.accentColor.opacity(0.8))
                            .overlay {
                                let opponent = gameManager.game.turns.last?.team.opponent() ?? .team1
                                Text("Next Turn: \(opponent.rawValue)")
                                    .font(.title3)
                                    .bold()
                            }
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 70)
                .listRowInsets(.init(top: 0, leading: 4, bottom: 0, trailing: 4))
            }

            // TODO: turn-by-turn scores
            Section("Game Scores") {
                let team1Score = gameManager.game.pointsFor(team: .team1)
                let team2Score = gameManager.game.pointsFor(team: .team2)
                HStack {
                    VStack(spacing: 15) {
                        Text("\(team1Score)")
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .shadow(radius: 2)

                        Text("\(team1Score > team2Score ? "👑 " : "")Team 1")
                            .font(.title3)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                        .padding(.horizontal, 8)

                    VStack(spacing: 15) {
                        Text("\(team2Score)")
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .shadow(radius: 2)

                        Text("\(team2Score > team1Score ? "👑 " : "")Team 2")
                            .font(.title3)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 10)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
            }
        }
        .scrollContentBackground(.hidden)
        .background {
            Color(uiColor: .systemBackground)
        }
    }
}

#Preview {
    IntermissionView(
        gameManager: .init(
            game: .init(turns: [
                .init(
                    team: .team1,
                    wonCards: (0..<3).map { _ in .init() },
                    forfeitedCards: [.init()]
                ),
                .init(
                    team: .team2,
                    wonCards: (0..<2).map { _ in .init() },
                    forfeitedCards: (0..<1).map { _ in .init() }
                ),
            ]),
            cardProvider: SNTestingCardProvider()
        ),
        turnStart: {
        }
    )
}

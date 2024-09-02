//
//  GameStatsView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 2/9/24.
//

import SwiftUI
import Charts

struct GameStatsView: View {
    let game: SNGame

    let team1Points: Int
    let team2Points: Int

    init(game: SNGame) {
        self.game = game
        self.team1Points = game.pointsFor(team: .team1)
        self.team2Points = game.pointsFor(team: .team2)
    }

    var winner: SNTeam? {
        if team1Points > team2Points {
            return .team1
        } else if team2Points > team1Points {
            return .team2
        } else {
            return nil
        }
    }

    var body: some View {
        List {
            winnerSection
            gameScoresSection
            scoresChartSection
            turnBreakdownSection
        }
        .scrollContentBackground(.hidden)
        .background {
            Color(uiColor: .systemBackground)
        }
    }

    var winnerSection: some View {
        Section {
            VStack(alignment: .center) {
                if let winner {
                    Image(systemName: "crown.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.yellow)
                        .frame(width: 60, height: 60)
                        .symbolEffect(.bounce, options: .nonRepeating)

                    Text(winner.rawValue)
                        .font(.largeTitle)
                        .bold()
                } else {
                    Text("Tie!")
                        .font(.largeTitle)
                        .bold()
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    var gameScoresSection: some View {
        Section("Game Scores") {
            HStack {
                VStack(spacing: 15) {
                    Text("\(team1Points)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("\(team1Points > team2Points ? "👑 " : "")Team 1")
                        .font(.title3)
                        .bold()
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .padding(.horizontal, 8)

                VStack(spacing: 15) {
                    Text("\(team2Points)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("\(team2Points > team1Points ? "👑 " : "")Team 2")
                        .font(.title3)
                        .bold()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 10)
            .listRowBackground(Color(uiColor: .systemGroupedBackground))
        }
    }

    var scoresChartSection: some View {
        Section("Scores Over Time") {
            Chart {
                LineMark(
                    x: .value("Turn", 0),
                    y: .value("Team 1 Points", 0)
                )
                .foregroundStyle(by: .value("Team Color", "Team 1"))

                LineMark(
                    x: .value("Turn", 0),
                    y: .value("Team 2 Points", 0)
                )
                .foregroundStyle(by: .value("Team Color", "Team 2"))

                ForEach(0..<game.turns.count, id: \.self) { index in
                    LineMark(
                        x: .value("Turn", index+1),
                        y: .value("Team 1 Points", game.pointsFor(
                            team: .team1,
                            upToTurn: index
                        ))
                    )
                    .foregroundStyle(by: .value("Team Color", "Team 1"))

                    LineMark(
                        x: .value("Turn", index+1),
                        y: .value("Team 2 Points", game.pointsFor(
                            team: .team2,
                            upToTurn: index
                        ))
                    )
                    .foregroundStyle(by: .value("Team Color", "Team 2"))
                }
            }
            .chartForegroundStyleScale([
                "Team 1": .green, "Team 2": .purple
            ])
            .padding(.top, 14)
            .padding(.bottom, 10)
            .listRowBackground(Color(uiColor: .systemGroupedBackground))
        }
    }

    var turnBreakdownSection: some View {
        Section("Turn Breakdown") {
            Text("TODO")
        }
    }
}

private extension SNTurn {
    init(team: SNTeam, won: Int, forfeit: Int) {
        self.init(
            team: team,
            wonCards: (0..<won).map { index in
                .init(
                    word: "Won \(index)",
                    forbiddenWords: ["A", "B", "C", "D", "E"].map { "\($0)\(index)" }
                )
            },
            forfeitedCards: (0..<forfeit).map { index in
                .init(
                    word: "Forfeit \(index)",
                    forbiddenWords: ["V", "W", "X", "Y", "Z"].map { "\($0)\(index)" }
                )
            }
        )
    }
}

#Preview {
    GameStatsView(
        game: .init(
            turns: [
                .init(team: .team1, won: 3, forfeit: 1),
                .init(team: .team2, won: 4, forfeit: 0),
                .init(team: .team1, won: 5, forfeit: 1),
                .init(team: .team2, won: 3, forfeit: 0),
                .init(team: .team1, won: 1, forfeit: 0),
                .init(team: .team2, won: 5, forfeit: 2)
            ]
        )
    )
}

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

    enum Statistic: CaseIterable {
        case averageWon
        case averageForfeit
        case bestTurn

        var description: String {
            switch self {
            case .averageWon: "Average Cards Won per Turn"
            case .averageForfeit: "Average Cards Forfeited per Turn"
            case .bestTurn: "Points won in best turn"
            }
        }

        func `for`(game: SNGame, team: SNTeam) -> Double {
            let relevantGames = game.turns.filter { $0.team == team }

            switch self {
            case .averageWon:
                let total = relevantGames.reduce(0) { partialResult, value in
                    partialResult + value.wonCards.count
                }

                return Double(total) / Double(relevantGames.count)
            case .averageForfeit:
                let total = relevantGames.reduce(0) { partialResult, value in
                    partialResult + value.forfeitedCards.count
                }

                return Double(total) / Double(relevantGames.count)
            case .bestTurn:
                let best = relevantGames.max { $0.netPoints < $1.netPoints }
                return Double(best?.netPoints ?? 0)
            }
        }
    }

    var body: some View {
        List {
            winnerSection
            gameScoresSection
            scoresChartSection
            statsSection
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
                "Team 1": .orange, "Team 2": .purple
            ])
            .padding(.top, 14)
            .padding(.bottom, 10)
            .listRowBackground(Color(uiColor: .systemGroupedBackground))
        }
    }

    var statsSection: some View {
        Section("Stats") {
            VStack {
                HStack {
                    Spacer()
                    Text("Team 1")
                    Spacer()
                    Text("Stat")
                    Spacer()
                    Text("Team 2")
                    Spacer()
                }
                Divider()
            }
            .padding(.top, 5)

            ForEach(Statistic.allCases, id: \.self) { stat in
                HStack {
                    Spacer()
                    Text(String(
                        format: "%.1f",
                        stat.for(game: game, team: .team1)
                    ))
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.orange)

                    Spacer()

                    Text(stat.description)
                        .font(.system(.subheadline, weight: .bold))
                        .multilineTextAlignment(.center)
                        .containerRelativeFrame(.horizontal, count: 3, spacing: 0)

                    Spacer()

                    Text(String(
                        format: "%.1f",
                        stat.for(game: game, team: .team2)
                    ))
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.purple)
                    Spacer()
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color(uiColor: .systemGroupedBackground))
    }

    var turnBreakdownSection: some View {
        Section("Turn Breakdown") {
            VStack {
                HStack {
                    Spacer()
                    Text("Won")
                    Spacer()
                    Text("Team Name")
                    Spacer()
                    Text("Forfeit")
                    Spacer()
                }
                Divider()
            }
            .padding(.top, 5)

            ForEach(game.turns, id: \.id) { turn in
                HStack {
                    Spacer()
                    Text("\(turn.wonCards.count)")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.green)
                    Spacer()
                    Text(turn.team.rawValue)
                        .font(.system(.title, weight: .bold))
                    Spacer()
                    Text("\(turn.wonCards.count)")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.red)
                    Spacer()
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    GameStatsView(
        game: .init(
            turns: [
                .init(team: .team1, won: 10, forfeit: 1),
                .init(team: .team2, won: 4, forfeit: 0),
                .init(team: .team1, won: 5, forfeit: 1),
                .init(team: .team2, won: 3, forfeit: 1),
                .init(team: .team1, won: 1, forfeit: 0),
                .init(team: .team2, won: 5, forfeit: 2)
            ]
        )
    )
}

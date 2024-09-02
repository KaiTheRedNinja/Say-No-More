//
//  GameSummaryView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 2/9/24.
//

import SwiftUI

struct GameSummaryView: View {
    var game: SNGame
    var date: Date

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.background)

            RoundedRectangle(cornerRadius: 14)
                .fill(Color.indigo.opacity(0.2))
                .stroke(
                    Color.indigo,
                    style: .init(
                        lineWidth: 10,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
        }
        .overlay(alignment: .top) {
            Text(date.formatted(date: .abbreviated, time: .shortened))
                .foregroundStyle(.background)           // make it non-primary
                .font(.system(.title, weight: .bold))   // big font size
                .minimumScaleFactor(0.3)                // can be scaled down to fit content
                .lineLimit(2)                           // but allow two lines first
                .frame(maxWidth: .infinity)             // make the text as wide as possible
                .padding(.vertical, 5)                  // padding of 5 around the text, vertically
                .padding(.horizontal, 8)                // padding of 8 around the text, horizontally
                .background {                           // background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.indigo)
                }
                .padding(.horizontal, 15)               // for the corners of the rectangle
                .visualEffect { original, geom in       // verticall center with outline
                    original
                        .offset(y: -geom.size.height/2)
                }
        }
        .overlay {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    cardContent
                    Spacer()
                }
                Spacer()
            }
            .multilineTextAlignment(.center)
            .padding(.top, 15)
        }
        .aspectRatio(0.8, contentMode: .fit)
        .padding(.top, 28)
    }

    var cardContent: some View {
        LazyVGrid(columns: .init(repeating: .init(), count: 2)) {
            VStack {
                Text("Turns\nPlayed")
                    .font(.caption)

                Text(String(game.turns.count))
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.blue)
            }
            .padding(.vertical, 8)

            VStack {
                Text("Cards\nGuessed")
                    .font(.caption)

                Text(String(game.turns.reduce(0, { $0 + $1.wonCards.count })))
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.green)
            }
            .padding(.vertical, 8)

            VStack {
                Text("Team 1")
                    .font(.caption)

                Text(String(game.pointsFor(team: .team1)))
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.orange)
            }

            VStack {
                Text("Team 2")
                    .font(.caption)

                Text(String(game.pointsFor(team: .team2)))
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.purple)
            }
        }
    }
}

#Preview {
    GeometryReader { geom in
        ScrollView {
            LazyVGrid(
                columns: .init(repeating: .init(), count: Int(geom.size.width / 150))
            ) {
                ForEach(0..<10) { _ in
                    GameSummaryView(
                        game: .init(
                            turns: [
                                .init(team: .team1, won: 10, forfeit: 1),
                                .init(team: .team2, won: 4, forfeit: 0),
                                .init(team: .team1, won: 5, forfeit: 1),
                                .init(team: .team2, won: 3, forfeit: 1),
                                .init(team: .team1, won: 1, forfeit: 0),
                                .init(team: .team2, won: 5, forfeit: 2)
                            ]
                        ),
                        date: .now
                    )
                    .padding(10)
                }
            }
            .padding(10)
        }
    }
}

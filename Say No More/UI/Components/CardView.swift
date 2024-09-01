//
//  CardView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 1/9/24.
//

import SwiftUI

struct CardView: View {
    var card: SNCard
    var cardColor: Color = .blue

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor.opacity(0.15))
                .stroke(
                    cardColor,
                    style: .init(
                        lineWidth: 10,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
        }
        .overlay(alignment: .top) {
            Text(card.word)
                .foregroundStyle(.background)           // make it non-primary
                .font(.system(.title, weight: .bold))   // big font size
                .minimumScaleFactor(0.3)                // can be scaled down to fit content
                .lineLimit(1)                           // but allow two lines first
                .frame(maxWidth: .infinity)             // make the text as wide as possible
                .padding(.vertical, 5)                  // padding of 5 around the text, vertically
                .padding(.horizontal, 8)                // padding of 8 around the text, horizontally
                .background {                           // background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(cardColor)
                }
                .padding(.horizontal, 24)               // for the corners of the rectangle
                .visualEffect { original, geom in       // verticall center with outline
                    original
                        .offset(y: -geom.size.height/2)
                }
        }
        .overlay {
            VStack {
                Spacer()
                Spacer()
                ForEach(card.forbiddenWords, id: \.self) { forbiddenWord in
                    Text(forbiddenWord)
                        .font(.system(.title, weight: .semibold))
                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(0.62, contentMode: .fit)
    }
}

#Preview {
    CardView(
        card: .init(
            word: "🚂 Locomotive",
            forbiddenWords: [
                "train",
                "steam",
                "engine",
                "tracks",
                "conductor"
            ]
        )
    )
    .containerRelativeFrame([.horizontal, .vertical]) { dimension, _ in
        dimension * 0.55
    }
}

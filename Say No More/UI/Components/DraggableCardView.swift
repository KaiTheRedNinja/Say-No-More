//
//  DraggableCardView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 2/9/24.
//

import SwiftUI

@Observable
class DraggableCardData {
    var card: SNCard
    var state: DraggableCardState = .idle

    init(card: SNCard) {
        self.card = card
    }

    enum DraggableCardState {
        case idle
        case won
        case forfeit
    }
}

struct DraggableCardView: View {
    @State var data: DraggableCardData
    var screenRect: CGRect = .zero

    var markWon: () -> Void
    var markForfeit: () -> Void
    var animationComplete: () -> Void

    @State private var dragTranslation: CGSize = .zero
    @State private var cardScale: CGFloat = 0

    /// Creates a draggable card view
    /// - Parameters:
    ///   - data: The data associated with the draggable card
    ///   - screenRect: A rectangle outlining the screen
    ///   - markWon: A closure that is called when the card is decided as won
    ///   - markForfeit: A closure that is called when the card is decided as forfeit
    ///   - animationComplete: A closure that is called when the win/forfeit animation finishes
    init(
        data: DraggableCardData,
        screenRect: CGRect,
        markWon: @escaping () -> Void,
        markForfeit: @escaping () -> Void,
        animationComplete: @escaping () -> Void
    ) {
        self.data = data
        self.screenRect = screenRect
        self.markWon = markWon
        self.markForfeit = markForfeit
        self.animationComplete = animationComplete
    }

    var body: some View {
        CardView(card: data.card)
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
            .frame(
                width: screenRect.width * 0.6,
                height: screenRect.height * 0.6
            )
            .onChange(of: data.state) { _, newValue in
                switch newValue {
                case .idle: break
                case .won: sendCard(won: true)
                case .forfeit: sendCard(won: false)
                }
            }
            .onAppear {
                withAnimation(.bouncy) {
                    cardScale = 1
                }
            }
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
        data.state = won ? .won : .forfeit
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
            markWon()
        } else {
            markForfeit()
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
            animationComplete()
        }
    }
}

#Preview {
    GeometryReader { geom in
        ZStack {
            Color.clear

            DraggableCardView(
                data: .init(
                    card: .init(
                        word: "Lighthouse",
                        forbiddenWords: [
                            "Beacon",
                            "Coastline",
                            "Navigation",
                            "Signal",
                            "Tower"
                        ]
                    )
                ),
                screenRect: geom.frame(in: .global),
                markWon: {},
                markForfeit: {},
                animationComplete: {}
            )
        }
    }
}

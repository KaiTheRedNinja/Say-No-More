//
//  HomeView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 2/9/24.
//

import SwiftUI

struct HomeView: View {
    var cardProvider: any SNCardProvider
    @State var archive: any ArchiveManager
    @State var showGamePlay: Bool = false

    init(cardProvider: any SNCardProvider, archive: any ArchiveManager) {
        self.cardProvider = cardProvider
        self.archive = archive
    }

    var body: some View {
        GeometryReader { geom in
            List {
                Section {
                    VStack(alignment: .center) {
                        Text("Say No More")
                            .font(.largeTitle)
                            .bold()

                        Text("🤐")
                            .font(.system(size: 100))
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    Button {
                        showGamePlay = true
                    } label: {
                        Text("Play!")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }

                Section("Past Games") {
                    LazyVGrid(
                        columns: .init(repeating: .init(), count: Int(geom.size.width / 150))
                    ) {
                        ForEach(archive.getGameDates(), id: \.self) { date in
                            if let game = archive.readGame(for: date) {
                                GameSummaryView(game: game, date: date)
                                    .padding(10)
                            }
                        }
                    }
                    .padding(-5)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .scrollContentBackground(.hidden)
            .background {
                Color(uiColor: .systemBackground)
            }
        }
        .fullScreenCover(isPresented: $showGamePlay) {
            // TODO: use actual card provider
            GameView(
                gameManager: .init(cardProvider: cardProvider),
                archive: archive
            )
        }
    }
}

#Preview {
    HomeView(
        cardProvider: SNSequentialCardProvider(),
        archive: SNArchiveMockManager.shared
    )
}

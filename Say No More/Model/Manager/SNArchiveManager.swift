//
//  SNArchiveManager.swift
//  Say No More
//
//  Created by Kai Quan Tay on 2/9/24.
//

import Foundation

protocol ArchiveManager: Observation.Observable {
    static var shared: Self { get }

    func getGameDates() -> [Date]
    func readGame(for date: Date) -> SNGame?
    func saveGame(_ game: SNGame, for date: Date)
    func removeGame(for date: Date)
}

@Observable
final class SNArchiveManager: ArchiveManager {
    var gameDates: [Date] = []
    private var gamesArchive: [Date: SNGame] = [:]

    private init(gameDates: [Date]) {
        self.gameDates = gameDates
    }

    static let shared: SNArchiveManager = {
        if let gameDates = FileSystem.read([Date].self, from: "directory.json") {
            .init(gameDates: gameDates)
        } else {
            .init(gameDates: [])
        }
    }()

    func getGameDates() -> [Date] {
        gameDates
    }

    func readGame(for date: Date) -> SNGame? {
        if let game = gamesArchive[date] {
            return game
        }

        if let game = FileSystem.read(SNGame.self, from: fileNameForGameWith(date: date)) {
            gamesArchive[date] = game
            return game
        }

        return nil
    }

    func saveGame(_ game: SNGame, for date: Date = Date()) {
        gameDates.append(date)
        gamesArchive[date] = game

        FileSystem.write(game, to: fileNameForGameWith(date: date))
        FileSystem.write(gameDates, to: "directory.json")
    }

    func removeGame(for date: Date) {
        gameDates.removeAll(where: { $0 == date })
        gamesArchive.removeValue(forKey: date)

        FileSystem.delete(file: fileNameForGameWith(date: date))
        FileSystem.write(gameDates, to: "directory.json")
    }

    private func fileNameForGameWith(date: Date) -> String {
        "game-\(date.timeIntervalSince1970).json"
    }
}

final class SNArchiveMockManager: ArchiveManager {
    var gamesArchive: [Date: SNGame] = [:]

    private init(gamesArchive: [Date: SNGame]) {
        self.gamesArchive = gamesArchive
    }

    static var shared: SNArchiveMockManager = .init(
        gamesArchive: {
            var archive: [Date: SNGame] = [:]
            for interval in 1..<10 {
                archive[.now.addingTimeInterval(Double(interval) * 60)] = .init(
                    turns: [
                        .init(team: .team1, won: 10, forfeit: 1),
                        .init(team: .team2, won: 4, forfeit: 0),
                        .init(team: .team1, won: 5, forfeit: 1),
                        .init(team: .team2, won: 3, forfeit: 1),
                        .init(team: .team1, won: 1, forfeit: 0),
                        .init(team: .team2, won: 5, forfeit: 2)
                    ]
                )
            }
            return archive
        }()
    )

    func getGameDates() -> [Date] {
        gamesArchive.keys.sorted()
    }

    func readGame(for date: Date) -> SNGame? {
        print("READING GAME: \(date)")
        return gamesArchive[date]
    }

    func saveGame(_ game: SNGame, for date: Date) {
        gamesArchive[date] = game
    }

    func removeGame(for date: Date) {
        gamesArchive.removeValue(forKey: date)
    }
}

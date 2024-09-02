//
//  SNArchiveManager.swift
//  Say No More
//
//  Created by Kai Quan Tay on 2/9/24.
//

import Foundation

@Observable
class SNArchiveManager {
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

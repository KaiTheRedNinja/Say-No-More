//
//  SNLLMCardProvider.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import Foundation
import OpenAI

private let replacementThreshold: Int = 5
class SNLLMCardProvider: SNCardProvider {
    let openAI: OpenAI
    var cardBank: [SNCard]
    private var wordBank: WordBank

    static let shared: SNLLMCardProvider = .init()

    private init() {
        self.openAI = OpenAI(apiToken: Secrets.key)
        if let wordBank = FileSystem.read(WordBank.self, from: "wordBank.json") {
            self.wordBank = wordBank
        } else {
            let filePath = Bundle.main.url(forResource: "nounlist", withExtension: "txt")!
            let words = (try? String(contentsOf: filePath, encoding: .utf8).split(separator: "\n")) ?? []
            self.wordBank = .init(
                index: 0,
                words: words.shuffled().map { String($0) }
            )
        }
        self.cardBank = FileSystem.read([SNCard].self, from: "cardBank.json") ?? []
    }

    func takeCard() -> SNCard? {
        defer {
            if !cardBank.isEmpty {
                cardBank.removeFirst()
            }

            if cardBank.count < replacementThreshold {
                Task {
                    do {
                        try await generateNewCards()
                    } catch {
                        print("ERROR: \(error)")
                    }
                }
            }
        }

        return cardBank.first
    }

    /// Called when the app is started, this ensures that there is a decent supply of cards.
    /// Does nothing if the cards bank has enough cards.
    func ensureCardBank() {
        guard cardBank.count < replacementThreshold else { return }

        Task {
            try await generateNewCards()
        }
    }

    private func cardsPrompt(count: Int = replacementThreshold, words: [String]) -> String {
        """
        You are a vocabulary expert. I will give you five words, which will be nouns. Then, for each \
        word, list five other words associated with it, in bullet points. Respond exactly with this \
        format, with no bolded or italicised words, in JSON:
        {
            "words": [
                {
                    word: // Word 1 here,
                    associatedWords: [
                        // associated word a here,
                        // associated word b here,
                        // associated word c here,
                        // associated word d here,
                        // associated word e here
                    ]
                },
                // repeat the above \(count) times
            ]
        }

        The words are: \(words.joined(separator: ", ")).
        """
    }

    private func generateNewCards() async throws {
        let query = ChatQuery(
            messages: [
                .init(role: .user, content: cardsPrompt(words: wordBank.getWords(replacementThreshold)))!
            ],
            model: .gpt4_o_mini,
            responseFormat: .jsonObject
        )

        let result = try await openAI.chats(query: query)

        guard let string = result.choices.first?.message.content?.string else { return }

        let decoded = try JSONDecoder().decode(LLMResponse.self, from: string.data(using: .utf8)!)

        cardBank.append(contentsOf: decoded.toSNCards())

        FileSystem.write(cardBank, to: "cardBank.json")
    }
}

private struct WordBank: Codable {
    var index: Int
    var words: [String]

    mutating func getWords(_ count: Int) -> [String] {
        defer {
            index = (index + count) % words.count
        }

        // if its too much, wrap around
        if count + index >= words.count {
            index = 0
            words.shuffle()
        }

        return Array(words[index..<(index+count)])
    }
}

private struct LLMResponse: Codable {
    struct LLMWordResponse: Codable {
        var word: String
        var associatedWords: [String]

        func toSNCard() -> SNCard {
            .init(id: .init(), word: word, forbiddenWords: associatedWords)
        }
    }

    var words: [LLMWordResponse]

    func toSNCards() -> [SNCard] {
        words.map { $0.toSNCard() }
    }
}

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

    static let shared: SNLLMCardProvider = .init()

    private init() {
        self.openAI = OpenAI(apiToken: Secrets.key)
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

    private func cardsPrompt(count: Int = replacementThreshold) -> String {
        """
        You are a vocabulary expert. I want you to come up with five nouns, which aren't common \
        (no "cat", "phone", etc), but is still likely to be known by a vast majority of people. \
        Then, for each word, list five words associated with the word, in bullet points. Respond \
        exactly with this format, with no bolded or italicised words, in JSON:
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
        """
    }

    private func generateNewCards() async throws {
        let query = ChatQuery(
            messages: [
                .init(role: .user, content: cardsPrompt())!
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

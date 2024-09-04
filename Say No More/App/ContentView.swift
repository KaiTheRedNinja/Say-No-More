//
//  ContentView.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView(
            cardProvider: SNLLMCardProvider.shared,
            archive: SNArchiveManager.shared
        )
    }
}

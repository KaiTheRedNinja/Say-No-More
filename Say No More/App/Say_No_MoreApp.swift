//
//  Say_No_MoreApp.swift
//  Say No More
//
//  Created by Kai Quan Tay on 31/8/24.
//

import SwiftUI

@main
struct Say_No_MoreApp: App { // swiftlint:disable:this type_name
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    SNLLMCardProvider.shared.ensureCardBank()
                }
        }
    }
}

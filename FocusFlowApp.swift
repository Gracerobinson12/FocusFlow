//
//  FocusFlowApp.swift
//  FocusFlow
//
//  Created by Grace Robinson on 7/26/26.
//

//
//  FocusFlowApp.swift
//  FocusFlow
//

import SwiftUI

@main
struct FocusFlowApp: App {
    @StateObject private var store = SessionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

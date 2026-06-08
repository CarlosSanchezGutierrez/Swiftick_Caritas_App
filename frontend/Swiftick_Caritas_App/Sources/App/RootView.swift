//
//  RootView.swift
//  Swiftick_Caritas_App
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ContentView()
        }
    }
}

//
//  RootView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext
    @StateObject private var lugaresVM = lugaresVM()

    var body: some View {
        NavigationStack {
            ContentView()
        }
        .task {
            await lugaresVM.syncCatalogo(context: modelContext)
        }
    }
}

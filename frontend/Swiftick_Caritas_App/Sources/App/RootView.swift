//
//  RootView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext
    @StateObject private var lugares = lugaresVM()
    @StateObject private var doctores = doctorVM()

    var body: some View {
        NavigationStack {
            ContentView()
        }
        .task {
            await lugares.syncCatalogo(context: modelContext)
            await doctores.syncDoctores(context: modelContext)
        }
    }
}

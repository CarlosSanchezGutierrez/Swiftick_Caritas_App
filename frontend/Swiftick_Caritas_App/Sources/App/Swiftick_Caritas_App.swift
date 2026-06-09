//
//  Swiftick_Caritas_AppApp.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

@main
struct Swiftick_Caritas_App: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
        .modelContainer(for: [
            Paciente.self, Doctor.self,
            paisLocal.self, estadoLocal.self, municipioLocal.self, ciudadLocal.self,
            domicilioLocal.self
        ])
    }
}

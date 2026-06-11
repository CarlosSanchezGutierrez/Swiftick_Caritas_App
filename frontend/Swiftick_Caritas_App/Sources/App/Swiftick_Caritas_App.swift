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
                .environment(\.font, .custom("Gotham Book", size: 16))
        }
        .modelContainer(for: [
            Paciente.self, Doctor.self,
            paisLocal.self, estadoLocal.self, municipioLocal.self, ciudadLocal.self,
            domicilioLocal.self,
            ConsultaLocal.self, SignosFisicosLocal.self,
            BrigadaLocal.self
        ])
    }
}

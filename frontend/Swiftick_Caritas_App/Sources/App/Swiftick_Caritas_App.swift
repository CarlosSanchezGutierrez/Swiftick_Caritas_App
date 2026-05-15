//
//  Swiftick_Caritas_AppApp.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 23/04/26.
//

import SwiftUI
import SwiftData

@main
struct Swiftick_Caritas_App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Paciente.self, Doctor.self])
    }
}

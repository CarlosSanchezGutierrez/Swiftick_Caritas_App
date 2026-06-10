//
//  AppState.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isOffline: Bool = false
    @Published var isSyncing: Bool = false

    @Published var brigadas: [Brigada] = [
        Brigada(nombre: "San Bernabé",       tipo: "Médica Integral", ruta: "Norte",
                servicios: ["Consulta General", "Odontología", "Entrega de medicamentos"]),
        Brigada(nombre: "Valle de las Salinas", tipo: "Médica General", ruta: "Sur",
                servicios: ["Consulta General", "Entrega de medicamentos"]),
        Brigada(nombre: "Monterrey",          tipo: "Médica General", ruta: "Centro",
                servicios: ["Consulta General", "Odontología", "Entrega de medicamentos"]),
    ]
    @Published var brigadaActiva: Brigada? = nil
}

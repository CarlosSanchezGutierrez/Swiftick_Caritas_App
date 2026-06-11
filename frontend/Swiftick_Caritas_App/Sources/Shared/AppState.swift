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

    @Published var brigadas: [Brigada] = []
    @Published var brigadaActiva: Brigada? = nil
}

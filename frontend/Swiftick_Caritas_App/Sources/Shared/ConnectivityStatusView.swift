//
//  ConnectivityStatusView.swift
//  Swiftick_Caritas_App
//

import SwiftUI

struct ConnectivityStatusView: View {
    @ObservedObject var appState: AppState
    var pendingCount: Int
    var onSync: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if !appState.isOffline && pendingCount > 0 {
                Button(action: onSync) {
                    HStack(spacing: 4) {
                        if appState.isSyncing {
                            ProgressView()
                                .scaleEffect(0.65)
                                .frame(width: 12, height: 12)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption.weight(.semibold))
                        }
                        Text(appState.isSyncing ? "Sincronizando…" : "\(pendingCount) pendiente\(pendingCount == 1 ? "" : "s")")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.blue)
                }
                .disabled(appState.isSyncing)
            }

            Button {
                appState.isOffline.toggle()
            } label: {
                HStack(spacing: 5) {
                    Circle()
                        .fill(appState.isOffline ? Color.orange : Color.green)
                        .frame(width: 7, height: 7)
                    Text(appState.isOffline ? "Sin conexión" : "En línea")
                        .font(.caption.weight(.semibold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.regularMaterial)
                .clipShape(Capsule())
            }
        }
    }
}

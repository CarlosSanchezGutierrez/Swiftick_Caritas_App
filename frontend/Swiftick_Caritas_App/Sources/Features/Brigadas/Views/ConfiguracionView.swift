//
//  ConfiguracionView.swift
//  Swiftick_Caritas_App
//

import SwiftUI

// Pantone 320 C = #00A9B7
private let p320      = Color(red: 0/255, green: 169/255, blue: 183/255)
private let p320Light = Color(red: 0/255, green: 205/255, blue: 218/255)
private let p320Dark  = Color(red: 0/255, green: 122/255, blue: 138/255)

struct ConfiguracionView: View {
    @EnvironmentObject var appState: AppState
    @State private var irNuevaBrigada = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Brigadas Registradas")
                    .font(.gotham(.bold, size: 30))
                Spacer()
                Button {
                    irNuevaBrigada = true
                } label: {
                    Text("Nueva ")
                        .font(.gotham(.ultra, size: 20))
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.black)
                }
                .padding()
                .foregroundStyle(.white)
                .background(p320)
                .clipShape(Capsule())
            }
            .padding()

            List {
                ForEach(appState.brigadas) { brigada in
                    let esActiva = appState.brigadaActiva?.id == brigada.id
                    BrigadaRow(brigada: brigada, esActiva: esActiva) {
                        appState.brigadaActiva = brigada
                    }
                    .listRowBackground(
                        Group {
                            if esActiva {
                                AnimatedBrigadaBackground()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Color(UIColor.secondarySystemGroupedBackground)
                            }
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
            }
        }
        .navigationDestination(isPresented: $irNuevaBrigada) {
            NuevaBrigadaView()
        }
        .navigationTitle("Ajustes")
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Row

private struct BrigadaRow: View {
    let brigada: Brigada
    let esActiva: Bool
    let onActivar: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(brigada.nombre)
                    .font(.gotham(.bold, size: 22))
                    .foregroundStyle(esActiva ? .white : .primary)
                Spacer()
                if !esActiva {
                    Button("Activar", action: onActivar)
                        .font(.gotham(.bold, size: 16))
                        .buttonStyle(.borderedProminent)
                        .tint(p320Dark)
                }
            }
            Text("Brigada \(brigada.tipo)")
                .font(.gotham(.thin, size: 18))
                .foregroundStyle(esActiva ? .white.opacity(0.9) : .secondary)
            HStack(spacing: 16) {
                Label(brigada.fecha.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                Label("Unidad Móvil 1", systemImage: "truck.box")
                Label("Ruta \(brigada.ruta)", systemImage: "location")
            }
            .font(.gotham(.book, size: 13))
            .foregroundStyle(esActiva ? .white.opacity(0.85) : .secondary)
            ServiceTagsRow(servicios: brigada.servicios, esActiva: esActiva)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Animated background

private struct AnimatedBrigadaBackground: View {
    @State private var phase = false

    var body: some View {
        LinearGradient(
            colors: phase
                ? [p320Dark, p320, p320Light]
                : [p320Light, p320, p320Dark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                phase = true
            }
        }
    }
}

// MARK: - Service tags

private struct ServiceTagsRow: View {
    let servicios: [String]
    let esActiva: Bool

    var body: some View {
        HStack(spacing: 6) {
            ForEach(servicios, id: \.self) { item in
                Text(item)
                    .font(.gotham(.book, size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(esActiva
                                ? Color.white.opacity(0.25)
                                : Color(red: 209/255, green: 224/255, blue: 215/255).opacity(0.6))
                    .foregroundStyle(esActiva ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    NavigationStack { ConfiguracionView() }
        .environmentObject(AppState())
}

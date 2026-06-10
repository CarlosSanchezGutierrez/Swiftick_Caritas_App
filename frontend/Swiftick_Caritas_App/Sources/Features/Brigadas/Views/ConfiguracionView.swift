//
//  ConfiguracionView.swift
//  Swiftick_Caritas_App
//

import SwiftUI

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
                .foregroundStyle(Color.white)
                .background(Color(red: 0/255, green: 156/255, blue: 166/255))
                .clipShape(Capsule())
            }
            .padding()

            List {
                ForEach(appState.brigadas) { brigada in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(brigada.nombre)
                                .font(.gotham(.bold, size: 22))
                            Spacer()
                            let esActiva = appState.brigadaActiva?.id == brigada.id
                            Button(esActiva ? "Activa" : "Activar") {
                                appState.brigadaActiva = brigada
                            }
                            .font(.gotham(.bold, size: 16))
                            .buttonStyle(.borderedProminent)
                            .tint(esActiva
                                  ? Color(red: 0/255, green: 156/255, blue: 166/255)
                                  : .gray)
                            .disabled(esActiva)
                        }
                        Text("Brigada \(brigada.tipo)")
                            .font(.gotham(.thin, size: 18))
                        HStack(spacing: 16) {
                            Label(brigada.fecha.formatted(date: .abbreviated, time: .omitted),
                                  systemImage: "calendar")
                            Label("Unidad Móvil 1", systemImage: "truck.box")
                            Label("Ruta \(brigada.ruta)", systemImage: "location")
                        }
                        .font(.gotham(.book, size: 13))
                        .foregroundStyle(.secondary)
                        FlowLayout(brigada.servicios)
                    }
                    .padding(.vertical, 4)
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

private struct FlowLayout: View {
    let items: [String]
    init(_ items: [String]) { self.items = items }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.gotham(.book, size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 209/255, green: 224/255, blue: 215/255).opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    NavigationStack { ConfiguracionView() }
        .environmentObject(AppState())
}

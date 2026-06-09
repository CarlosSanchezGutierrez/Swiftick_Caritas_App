//
//  ConfiguracionView.swift
//  Swiftick_Caritas_App
//

import SwiftUI

struct ConfiguracionView: View {
    @State private var brigadas: [Brigada] = [
        Brigada(nombre: "San Bernabé", tipo: "Médica Integral", ruta: "Norte", servicios: [
            "Consulta General", "Odontología", "Entrega de medicamentos"
        ]),
        Brigada(nombre: "Valle de las Salinas", tipo: "Médica General", ruta: "Sur", servicios: [
            "Consulta General", "Entrega de medicamentos"
        ]),
        Brigada(nombre: "Monterrey", tipo: "Médica General", ruta: "Centro", servicios: [
            "Consulta General", "Odontología", "Entrega de medicamentos"
        ]),
    ]
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
                ForEach(brigadas) { brigada in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(brigada.nombre)
                                .font(.gotham(.bold, size: 22))
                            Spacer()
                            Button("Activar") {}
                                .font(.gotham(.bold, size: 16))
                                .buttonStyle(.borderedProminent)
                                .tint(Color(red: 0/255, green: 156/255, blue: 166/255))
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
}

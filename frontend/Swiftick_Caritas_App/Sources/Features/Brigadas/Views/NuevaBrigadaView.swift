//
//  NuevaBrigadaView.swift
//  Swiftick_Caritas_App
//

import SwiftUI

struct NuevaBrigadaView: View {
    @Environment(\.dismiss) var dismiss

    @State private var fecha = Date()
    @State private var nombre = ""
    @State private var tipo = ""
    @State private var ruta = ""

    @State private var optometria = false
    @State private var general = false
    @State private var medicamentos = false
    @State private var dental = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("Nueva Brigada")
                    .font(.gotham(.black, size: 36))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha").font(.gotham(.medium, size: 18))
                    DatePicker("", selection: $fecha, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                campoTexto("Comunidad", binding: $nombre, placeholder: "Ej: San Bernabé")
                campoTexto("Tipo de Brigada", binding: $tipo, placeholder: "Ej: Médica Integral")
                campoTexto("Ruta", binding: $ruta, placeholder: "Ej: Norte")

                VStack(alignment: .leading, spacing: 12) {
                    Text("Servicios Disponibles").font(.gotham(.medium, size: 18))
                    Toggle("Optometría", isOn: $optometria)
                    Toggle("Consulta General", isOn: $general)
                    Toggle("Entrega de Medicamentos", isOn: $medicamentos)
                    Toggle("Consulta Dental", isOn: $dental)
                }
                .tint(Color(red: 0/255, green: 156/255, blue: 166/255))

                Button {
                    // TODO: persist brigada
                    dismiss()
                } label: {
                    Label("Guardar Brigada", systemImage: "checkmark")
                        .font(.gotham(.bold, size: 20))
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color(red: 0/255, green: 156/255, blue: 166/255))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(40)
        }
        .navigationTitle("Nueva Brigada")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func campoTexto(_ label: String, binding: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.gotham(.medium, size: 18))
            TextField(placeholder, text: binding)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview { NavigationStack { NuevaBrigadaView() } }

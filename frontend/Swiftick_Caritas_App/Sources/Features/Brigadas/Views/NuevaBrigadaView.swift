//
//  NuevaBrigadaView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct NuevaBrigadaView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @StateObject private var brigadasVM = brigadaVM()

    @Query(sort: \Doctor.nombre) private var doctores: [Doctor]
    @Query(sort: \ciudadLocal.nombre) private var todasCiudades: [ciudadLocal]

    @State private var fecha = Date()
    @State private var nombre = ""
    @State private var tipo = ""
    @State private var ruta = ""
    @State private var doctorSeleccionado: Doctor? = nil
    @State private var ciudadSeleccionada: ciudadLocal? = nil

    @State private var optometria = false
    @State private var general = false
    @State private var medicamentos = false
    @State private var dental = false

    @State private var errorNombre = false

    private var serviciosSeleccionados: [String] {
        var s: [String] = []
        if general      { s.append("Consulta General") }
        if dental       { s.append("Consulta Dental") }
        if medicamentos { s.append("Entrega de Medicamentos") }
        if optometria   { s.append("Optometría") }
        return s
    }

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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                campoTexto("Comunidad", binding: $nombre,
                           placeholder: "Ej: San Bernabé", error: errorNombre)
                campoTexto("Tipo de Brigada", binding: $tipo,
                           placeholder: "Ej: Médica Integral")
                campoTexto("Ruta", binding: $ruta, placeholder: "Ej: Norte")

                // Doctor picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Doctor Responsable").font(.gotham(.medium, size: 18))
                    Picker("Doctor", selection: $doctorSeleccionado) {
                        Text("Seleccionar...").tag(nil as Doctor?)
                        ForEach(doctores) { doc in
                            Text("\(doc.nombre) \(doc.apellidoP)").tag(doc as Doctor?)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Ciudad picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ciudad").font(.gotham(.medium, size: 18))
                    Picker("Ciudad", selection: $ciudadSeleccionada) {
                        Text("Seleccionar...").tag(nil as ciudadLocal?)
                        ForEach(todasCiudades) { ciudad in
                            Text(ciudad.nombre).tag(ciudad as ciudadLocal?)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Servicios Disponibles").font(.gotham(.medium, size: 18))
                    Toggle("Optometría",              isOn: $optometria)
                    Toggle("Consulta General",        isOn: $general)
                    Toggle("Entrega de Medicamentos", isOn: $medicamentos)
                    Toggle("Consulta Dental",         isOn: $dental)
                }
                .tint(Color(red: 0/255, green: 156/255, blue: 166/255))

                Button {
                    guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
                        errorNombre = true; return
                    }

                    var nueva = Brigada(
                        nombre: nombre, tipo: tipo,
                        fecha: fecha, ruta: ruta,
                        servicios: serviciosSeleccionados
                    )

                    let serviciosStr = serviciosSeleccionados.count
                    let doctorID = doctorSeleccionado?.dbID ?? 0
                    let ciudadID = ciudadSeleccionada?.id ?? 0
                    let municipioID = ciudadSeleccionada?.municipio?.id ?? 0
                    let nuevaID = nueva.id

                    if appState.isOffline {
                        _ = brigadasVM.storeBrigada(
                            context: modelContext,
                            doctorID: doctorID,
                            serviciosDisp: serviciosStr,  // count of selected services
                            fechaOp: fecha,
                            municipioID: municipioID,
                            ciudadID: ciudadID,
                            colonia: nombre
                        )
                    } else {
                        Task {
                            if let id = await brigadasVM.addBrigada(
                                doctorID: doctorID,
                                serviciosDisp: serviciosStr,
                                fechaOp: fecha,
                                municipioID: municipioID,
                                ciudadID: ciudadID,
                                colonia: nombre
                            ) {
                                await MainActor.run {
                                    if let idx = appState.brigadas.firstIndex(where: { $0.id == nuevaID }) {
                                        appState.brigadas[idx].dbID = id
                                    }
                                }
                            }
                        }
                    }

                    appState.brigadas.append(nueva)
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
    private func campoTexto(
        _ label: String, binding: Binding<String>,
        placeholder: String, error: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.gotham(.medium, size: 18))
            TextField(placeholder, text: binding)
                .textFieldStyle(.roundedBorder)
                .overlay(RoundedRectangle(cornerRadius: 6)
                    .stroke(error ? Color.red : Color.clear, lineWidth: 2))
            if error {
                Text("Campo obligatorio")
                    .foregroundStyle(.red).font(.caption)
            }
        }
    }
}

#Preview {
    NavigationStack { NuevaBrigadaView() }
        .environmentObject(AppState())
        .modelContainer(for: [Doctor.self, ciudadLocal.self, municipioLocal.self], inMemory: true)
}

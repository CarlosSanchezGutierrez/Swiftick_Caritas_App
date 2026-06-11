//
//  NuevaConsultaView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct NuevaConsultaView: View {
    var paciente: Paciente
    var doctorPrevio: Doctor? = nil
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = consultaVM()

    @Query(sort: \Doctor.nombre) private var doctores: [Doctor]

    let servicios = ["Consulta General", "Entrega de Medicamentos", "Optometría", "Consulta Dental"]
    let tallas    = ["XXS", "XS", "S", "M", "L", "XL", "XXL"]

    @State private var doctorSeleccionado: Doctor? = nil
    @State private var servicioElegido = ""
    @State private var folio: UUID     = UUID()
    @State private var fecha: Date     = .now
    @State private var imss            = false

    // Consulta General
    @State private var peso: Double       = 0
    @State private var talla              = ""
    @State private var perimAbdom: Double = 0
    @State private var presArterS: Double = 0
    @State private var presArterD: Double = 0
    @State private var pulso: Double      = 0
    @State private var frecCard: Double   = 0
    @State private var frecResp: Double   = 0

    // Entrega de Medicamentos
    @State private var medicina  = ""
    @State private var cantidad  = 0

    // Shared
    @State private var diagnostico = ""

    var body: some View {
        Form {
            // MARK: Doctor
            Section {
                Text("Doctor").font(.gotham(.black, size: 28)).listRowBackground(Color.clear)

                if let doc = doctorPrevio {
                    LabeledContent("Doctor responsable") {
                        Text("\(doc.nombre) \(doc.apellidoP)")
                            .font(.gotham(.book, size: 20))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Picker("Selecciona un doctor", selection: $doctorSeleccionado) {
                        Text("Seleccionar...").tag(nil as Doctor?)
                        ForEach(doctores) { doc in
                            Text("\(doc.nombre) \(doc.apellidoP)").tag(doc as Doctor?)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.gotham(.book, size: 20))
                }
            }

            // MARK: Servicio
            Section {
                Text("Servicio")
                    .font(.gotham(.black, size: 28))
                    .listRowBackground(Color.clear)

                Picker("Selecciona un servicio", selection: $servicioElegido) {
                    Text("Selecciona...").tag("")
                    ForEach(servicios, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .font(.gotham(.book, size: 20))
            }

            // MARK: Información General
            Section {
                Text("Información General")
                    .font(.gotham(.black, size: 28))
                    .listRowBackground(Color.clear)

                LabeledContent("Folio") {
                    Text(folio.uuidString.prefix(8).uppercased())
                        .font(.gotham(.book, size: 16))
                        .foregroundStyle(.secondary)
                }

                DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                    .font(.gotham(.book, size: 20))

                Toggle("¿Tiene IMSS?", isOn: $imss)
                    .font(.gotham(.book, size: 20))
                    .tint(Color(red: 0/255, green: 156/255, blue: 166/255))
            }

            // MARK: Campos condicionales
            if servicioElegido == "Consulta General" {
                Section("Signos Vitales") {
                    campoNumerico("Peso (kg)", value: $peso)

                    HStack {
                        Text("Talla").font(.gotham(.medium, size: 18))
                        Spacer()
                        Picker("Talla", selection: $talla) {
                            Text("Selecciona...").tag("")
                            ForEach(tallas, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .font(.gotham(.book, size: 18))
                    }

                    campoNumerico("Perímetro Abdominal (cm)", value: $perimAbdom)

                    HStack(spacing: 8) {
                        Text("Presión Arterial").font(.gotham(.medium, size: 18))
                        Spacer()
                        TextField("Sistólico", value: $presArterS, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("/").font(.gotham(.book, size: 20))
                        TextField("Diastólico", value: $presArterD, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("mmHg").font(.gotham(.book, size: 16)).foregroundStyle(.secondary)
                    }

                    campoNumerico("Pulso (lpm)", value: $pulso)
                    campoNumerico("Frecuencia Cardíaca (lpm)", value: $frecCard)
                    campoNumerico("Frecuencia Respiratoria (rpm)", value: $frecResp)
                }
            } else if servicioElegido == "Entrega de Medicamentos" {
                Section("Medicamento") {
                    LabeledContent("Nombre") {
                        TextField("Ingresar nombre...", text: $medicina)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Cantidad") {
                        TextField("0", value: $cantidad, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }

            // MARK: Diagnóstico
            Section("Diagnóstico / Notas") {
                TextEditor(text: $diagnostico)
                    .frame(minHeight: 150)
                    .font(.gotham(.book, size: 16))
            }
        }
        .navigationTitle("Nueva Consulta")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                guardarConsulta()
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Guardar y continuar")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .padding(3)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0/255, green: 156/255, blue: 166/255))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color(UIColor.systemBackground))
        }
    }

    private func guardarConsulta() {
        let doctorID   = doctorPrevio?.dbID ?? doctorSeleccionado?.dbID ?? 0
        let brigadaID  = appState.brigadaActiva?.dbID ?? 0
        let tipoPaciente = imss ? "IMSS" : "General"

        var signosLocal: SignosFisicosLocal? = nil
        if servicioElegido == "Consulta General" {
            signosLocal = vm.storeSignosFisicos(
                context: modelContext,
                pacienteID: paciente.dbID,
                peso: peso, talla: talla,
                perimAbdom: perimAbdom,
                presArterD: presArterD,
                presArterS: presArterS,
                pulso: pulso,
                frecCard: frecCard,
                frecResp: frecResp
            )
        }

        let consulta = vm.storeConsulta(
            context: modelContext,
            pacienteID: paciente.dbID,
            doctorID: doctorID,
            brigadaID: brigadaID,
            cantMedicina: servicioElegido == "Entrega de Medicamentos" ? cantidad : 0,
            tipoServicio: servicioElegido.isEmpty ? "General" : servicioElegido,
            fechaServicio: fecha,
            imss: imss,
            tipoPaciente: tipoPaciente,
            diagnostico: diagnostico
        )
        consulta.signosID = signosLocal?.id

        if let onSaved { onSaved() } else { dismiss() }
    }

    @ViewBuilder
    private func campoNumerico(_ label: String, value: Binding<Double>) -> some View {
        LabeledContent(label) {
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.gotham(.book, size: 18))
        }
        .font(.gotham(.medium, size: 18))
    }
}

#Preview {
    NavigationStack {
        NuevaConsultaView(paciente: Paciente(
            nombre: "Renata", apellidoP: "Méndez", apellidoM: "Rodríguez",
            genero: "Femenino", edad: 20, fechaNac: .now, familiares: 2, curp: "")
        )
    }
    .environmentObject(AppState())
    .modelContainer(for: [Paciente.self, Doctor.self, ConsultaLocal.self, SignosFisicosLocal.self], inMemory: true)
}

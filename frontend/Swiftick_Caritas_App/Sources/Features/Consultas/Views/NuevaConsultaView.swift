//
//  NuevaConsultaView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

private enum DoctorSelection: Hashable {
    case ninguno, nuevo, id(UUID)
}

struct NuevaConsultaView: View {
    var paciente: Paciente
    var doctorPrevio: Doctor? = nil
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = consultaVM()
    @StateObject private var patientVM = PatientIntakeViewModel()

    @Query(sort: \Doctor.nombre) private var doctores: [Doctor]

    let servicios = ["Consulta General", "Entrega de Medicamentos", "Optometría", "Consulta Dental"]
    let tallas    = ["XXS", "XS", "S", "M", "L", "XL", "XXL"]
    let opcionesGenero = ["Masculino", "Femenino", "No binario", "Prefiero no decir"]

    // Doctor selection
    @State private var doctorSelection = DoctorSelection.ninguno
    // New doctor form
    @State private var nuevoNombreDoc      = ""
    @State private var nuevoApellidoPDoc   = ""
    @State private var nuevoApellidoMDoc   = ""
    @State private var nuevoGeneroDoc      = ""
    @State private var nuevoFechaNacDoc    = Date()
    @State private var nuevoRealizandoPrac = false

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
    @State private var guardando = false

    private var formularioValido: Bool {
        let doctorOk: Bool
        if let _ = doctorPrevio {
            doctorOk = true
        } else {
            switch doctorSelection {
            case .ninguno: return false
            case .id:      doctorOk = true
            case .nuevo:
                doctorOk = !nuevoNombreDoc.trimmingCharacters(in: .whitespaces).isEmpty &&
                           !nuevoApellidoPDoc.trimmingCharacters(in: .whitespaces).isEmpty &&
                           !nuevoGeneroDoc.isEmpty
            }
        }
        guard doctorOk, !servicioElegido.isEmpty else { return false }
        switch servicioElegido {
        case "Consulta General":
            return !talla.isEmpty
        case "Entrega de Medicamentos":
            return !medicina.trimmingCharacters(in: .whitespaces).isEmpty && cantidad > 0
        default:
            return true
        }
    }

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
                    Picker("Selecciona un doctor", selection: $doctorSelection) {
                        Text("Seleccionar...").tag(DoctorSelection.ninguno)
                        Text("+ Nuevo Doctor").tag(DoctorSelection.nuevo)
                        ForEach(doctores) { doc in
                            Text("\(doc.nombre) \(doc.apellidoP)").tag(DoctorSelection.id(doc.doctorID))
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.gotham(.book, size: 20))

                    if doctorSelection == .nuevo {
                        LabeledContent("Nombre(s)") {
                            TextField("Ingresar nombre...", text: $nuevoNombreDoc)
                                .multilineTextAlignment(.trailing)
                        }
                        LabeledContent("Apellido paterno") {
                            TextField("Ingresar apellido...", text: $nuevoApellidoPDoc)
                                .multilineTextAlignment(.trailing)
                        }
                        LabeledContent("Apellido materno") {
                            TextField("Ingresar apellido...", text: $nuevoApellidoMDoc)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("Género", selection: $nuevoGeneroDoc) {
                            Text("Seleccionar").tag("")
                            ForEach(opcionesGenero, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .font(.gotham(.book, size: 20))
                        DatePicker("Fecha de nacimiento", selection: $nuevoFechaNacDoc, displayedComponents: .date)
                            .font(.gotham(.book, size: 20))
                        Toggle("¿Realizando prácticas?", isOn: $nuevoRealizandoPrac)
                            .font(.gotham(.book, size: 20))
                            .tint(Color(red: 0/255, green: 156/255, blue: 166/255))
                    }
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
            .background(formularioValido
                ? Color(red: 0/255, green: 156/255, blue: 166/255)
                : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(!formularioValido)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color(UIColor.systemBackground))
        }
    }

    private func guardarConsulta() {
        guard !guardando else { return }
        guardando = true

        let tipoPaciente = imss ? "IMSS" : "General"
        let brigadaID    = appState.brigadaActiva?.dbID ?? 0

        // Resolve doctorID and optionally create a new local Doctor
        var doctorID: Int
        var newDoctor: Doctor? = nil
        if let prev = doctorPrevio {
            doctorID = prev.dbID
        } else if case .id(let uuid) = doctorSelection,
                  let doc = doctores.first(where: { $0.doctorID == uuid }) {
            doctorID = doc.dbID
        } else {
            let doc = Doctor(
                nombre: nuevoNombreDoc, apellidoP: nuevoApellidoPDoc,
                apellidoM: nuevoApellidoMDoc, genero: nuevoGeneroDoc,
                fechaNac: nuevoFechaNacDoc, realizandoPrac: nuevoRealizandoPrac
            )
            modelContext.insert(doc)
            try? modelContext.save()
            newDoctor = doc
            doctorID = 0
        }

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
            localPacienteID: paciente.pacienteID.uuidString,
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
        try? modelContext.save()

        Task {
            // If a new doctor was just created, push it first and patch doctorID
            if let doc = newDoctor {
                await patientVM.syncNewDoctor(doc, context: modelContext)
                consulta.doctorID = doc.dbID
                try? modelContext.save()
            }
            if servicioElegido == "Entrega de Medicamentos", !medicina.trimmingCharacters(in: .whitespaces).isEmpty {
                consulta.medicamentosID = await vm.addMedicamento(nombre: medicina)
                try? modelContext.save()
            }
            await patientVM.syncConsultasOnly(context: modelContext, appState: appState)
        }

        guardando = false
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

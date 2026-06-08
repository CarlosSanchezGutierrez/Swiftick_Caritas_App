//
//  NuevoPacienteView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct NuevoPacienteView: View {
    var paciente: Paciente? = nil

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var mostrarFormulario = false
    @State private var firmaPriv = false
    @State private var firmaPrivacidad = false

    @State private var nombre = ""
    @State private var apellidoP = ""
    @State private var apellidoM = ""
    @State private var genero = ""
    @State private var fechaNacimiento = Date()
    @State private var curp = ""
    @State private var familiares = ""

    @State private var nombreDoc = ""
    @State private var apellidoPDOC = ""
    @State private var apellidoMDOC = ""
    @State private var generoDoc = ""
    @State private var realizandoPrac = false
    @State private var fechaNacDoc = Date()

    @State private var errorNombre = false
    @State private var errorApellidoP = false
    @State private var errorApellidoM = false
    @State private var errorGenero = false
    @State private var errorFamiliares = false
    @State private var errorNombreDoc = false
    @State private var errorApellidoPDoc = false
    @State private var errorApellidoMDoc = false
    @State private var errorGeneroDoc = false
    @State private var mensajeError = ""

    let opcionesGenero = ["Masculino", "Femenino", "No binario", "Prefiero no decir"]

    var isCreating: Bool { paciente == nil }

    var body: some View {
        Group {
            if !mostrarFormulario {
                privacyView
            } else {
                formView
            }
        }
        .onAppear {
            if let p = paciente {
                prefill(from: p)
                mostrarFormulario = true
            }
        }
    }

    // MARK: - Privacy Screen

    private var privacyView: some View {
        VStack {
            Text("AVISO DE PRIVACIDAD")
                .font(.title)
                .fontWeight(.bold)
            Text("Aquí iría el aviso de privacidad")
                .foregroundStyle(Color.blue)
            Toggle("He leído y acepto el aviso de privacidad.", isOn: $firmaPriv)
            Button("Confirmar") {
                firmaPrivacidad = true
                mostrarFormulario = true
            }
            .disabled(!firmaPriv)
            .padding()
            .frame(maxWidth: .infinity)
            .background(firmaPriv ? Color(red: 0/255, green: 156/255, blue: 166/255) : Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .navigationTitle("Aviso de Privacidad")
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: 5) {
                pacienteSection
                doctorSection

                if !mensajeError.isEmpty {
                    Text(mensajeError)
                        .foregroundStyle(Color.red)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }

                Button {
                    if validarFormulario() {
                        guardarPaciente()
                        guardarDoctor()
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                        Text("Guardar y continuar")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0/255, green: 156/255, blue: 166/255))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
        .background(Color(red: 242/255, green: 242/255, blue: 247/255))
        .navigationTitle(isCreating ? "Nuevo Paciente" : "Editar Paciente")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Paciente Section

    private var pacienteSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Información del paciente")
                .font(.title2)
                .fontWeight(.bold)

            campoTexto("Nombre(s)", texto: $nombre, placeholder: "Ingrese el nombre", error: errorNombre)
            campoTexto("Apellido paterno", texto: $apellidoP, placeholder: "Ingrese el apellido paterno", error: errorApellidoP)
            campoTexto("Apellido materno", texto: $apellidoM, placeholder: "Ingrese el apellido materno", error: errorApellidoM)

            VStack(alignment: .leading, spacing: 8) {
                Text("Género").fontWeight(.semibold)
                Picker("Género", selection: $genero) {
                    Text("Seleccionar").tag("")
                    ForEach(opcionesGenero, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(errorGenero ? Color.red : Color.clear, lineWidth: 2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                if errorGenero { errorCaption }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Fecha de nacimiento").fontWeight(.semibold)
                DatePicker("", selection: $fechaNacimiento, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("CURP").fontWeight(.semibold)
                TextField("Ingrese la CURP", text: $curp)
                    .textInputAutocapitalization(.characters)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            campoTexto("Número de familiares", texto: $familiares, placeholder: "Ingrese el número", soloNumeros: true, error: errorFamiliares)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(radius: 5)
    }

    // MARK: - Doctor Section

    private var doctorSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Información del doctor")
                .font(.title2)
                .fontWeight(.bold)

            campoTexto("Nombre(s)", texto: $nombreDoc, placeholder: "Ingrese el nombre", error: errorNombreDoc)
            campoTexto("Apellido paterno", texto: $apellidoPDOC, placeholder: "Ingrese el apellido paterno", error: errorApellidoPDoc)
            campoTexto("Apellido materno", texto: $apellidoMDOC, placeholder: "Ingrese el apellido materno", error: errorApellidoMDoc)

            VStack(alignment: .leading, spacing: 8) {
                Text("Género").fontWeight(.semibold)
                Picker("Género", selection: $generoDoc) {
                    Text("Seleccionar").tag("")
                    ForEach(opcionesGenero, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(errorGeneroDoc ? Color.red : Color.clear, lineWidth: 2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                if errorGeneroDoc { errorCaption }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Fecha de nacimiento").fontWeight(.semibold)
                DatePicker("", selection: $fechaNacDoc, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Toggle("¿Se encuentra realizando prácticas?", isOn: $realizandoPrac)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(radius: 5)
    }

    // MARK: - Helpers

    private var errorCaption: some View {
        Text("Este campo es obligatorio")
            .foregroundStyle(Color.red)
            .font(.caption)
    }

    @ViewBuilder
    private func campoTexto(
        _ label: String,
        texto: Binding<String>,
        placeholder: String,
        soloNumeros: Bool = false,
        error: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).fontWeight(.semibold)
            Group {
                if soloNumeros {
                    TextField(placeholder, text: texto).keyboardType(.numberPad)
                } else {
                    TextField(placeholder, text: texto)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(error ? Color.red : Color.clear, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if error { errorCaption }
        }
    }

    // MARK: - Logic

    private func prefill(from p: Paciente) {
        nombre = p.nombre
        apellidoP = p.apellidoP
        apellidoM = p.apellidoM
        genero = p.genero
        fechaNacimiento = p.fechaNac
        curp = p.curp == "Sin CURP" ? "" : p.curp
        familiares = "\(p.familiares)"
        firmaPrivacidad = p.firmaPrivacidad
    }

    private func validarFormulario() -> Bool {
        errorNombre      = nombre.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoP   = apellidoP.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoM   = apellidoM.trimmingCharacters(in: .whitespaces).isEmpty
        errorGenero      = genero.isEmpty
        errorFamiliares  = familiares.isEmpty
        errorNombreDoc   = nombreDoc.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoPDoc = apellidoPDOC.trimmingCharacters(in: .whitespaces).isEmpty
        errorApellidoMDoc = apellidoMDOC.trimmingCharacters(in: .whitespaces).isEmpty
        errorGeneroDoc   = generoDoc.isEmpty

        let hayErrores = errorNombre || errorApellidoP || errorApellidoM || errorGenero ||
            errorFamiliares || errorNombreDoc || errorApellidoPDoc || errorApellidoMDoc || errorGeneroDoc
        mensajeError = hayErrores ? "Por favor complete todos los campos obligatorios." : ""
        return !hayErrores
    }

    private func guardarPaciente() {
        let edadCalculada = Calendar.current.dateComponents([.year], from: fechaNacimiento, to: Date()).year ?? 0
        let intFam = Int(familiares) ?? 0

        if let existente = paciente {
            existente.nombre = nombre
            existente.apellidoP = apellidoP
            existente.apellidoM = apellidoM
            existente.genero = genero
            existente.edad = edadCalculada
            existente.fechaNac = fechaNacimiento
            existente.curp = curp.isEmpty ? "Sin CURP" : curp
            existente.familiares = intFam
            existente.firmaPrivacidad = firmaPrivacidad
        } else {
            let nuevo = Paciente(
                nombre: nombre, apellidoP: apellidoP, apellidoM: apellidoM,
                genero: genero, edad: edadCalculada, fechaNac: fechaNacimiento,
                familiares: intFam, curp: curp
            )
            nuevo.firmaPrivacidad = firmaPrivacidad
            modelContext.insert(nuevo)
        }
        try? modelContext.save()
    }

    private func guardarDoctor() {
        guard !nombreDoc.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let doctor = Doctor(
            nombre: nombreDoc, apellidoP: apellidoPDOC, apellidoM: apellidoMDOC,
            genero: generoDoc, fechaNac: fechaNacDoc, realizandoPrac: realizandoPrac
        )
        modelContext.insert(doctor)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        NuevoPacienteView()
    }
    .modelContainer(for: [Paciente.self, Doctor.self], inMemory: true)
}

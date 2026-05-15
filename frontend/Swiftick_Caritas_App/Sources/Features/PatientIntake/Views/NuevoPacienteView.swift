//
//  NuevoPacienteView.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 13/05/26.
//

import SwiftUI
import SwiftData

struct NuevoPacienteView: View {

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State var mostrarFormulario = false
    @State var firmaPriv = false

    @State var nombre = ""
    @State var apellidoP = ""
    @State var apellidoM = ""
    @State var genero = ""
    @State var edad = ""
    @State var fechaNacimiento = Date()
    @State var curp = ""
    @State var familiares = ""
    @State var firmaPrivacidad = false

    @State var nombreDoc = ""
    @State var apellidoPDOC = ""
    @State var apellidoMDOC = ""
    @State var generoDoc = ""
    @State var realizandoPrac = false
    @State var fechaNacDoc = Date()

    let opcionesGenero = ["Masculino", "Femenino", "No binario", "Prefiero no decir"]

    var body: some View {
        if !mostrarFormulario {
            VStack {
                Text("AVISO DE PRIVACIDAD")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Aquí iría el aviso de privacidad")
                    .foregroundStyle(Color.blue)
                Toggle("He leído y acepto el aviso de privacidad.", isOn: $firmaPriv)
                Button("Confirmar") {
                    if firmaPriv {
                        firmaPrivacidad = true
                        mostrarFormulario = true
                    }
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
        } else {
            ScrollView {
                VStack(spacing: 5) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Información del paciente")
                            .font(.title2)
                            .fontWeight(.bold)

                        campoTexto("Nombre(s)", texto: $nombre, placeholder: "Ingrese el nombre")
                        campoTexto("Apellido paterno", texto: $apellidoP, placeholder: "Ingrese el apellido paterno")
                        campoTexto("Apellido materno", texto: $apellidoM, placeholder: "Ingrese el apellido materno")

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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        campoTexto("Edad", texto: $edad, placeholder: "Ingrese la edad", teclado: .numberPad)

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

                        campoTexto("Número de familiares", texto: $familiares, placeholder: "Ingrese el número", teclado: .numberPad)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(radius: 5)

                    VStack(alignment: .leading, spacing: 18) {
                        Text("Información del doctor")
                            .font(.title2)
                            .fontWeight(.bold)

                        campoTexto("Nombre(s)", texto: $nombreDoc, placeholder: "Ingrese el nombre")
                        campoTexto("Apellido paterno", texto: $apellidoPDOC, placeholder: "Ingrese el apellido paterno")
                        campoTexto("Apellido materno", texto: $apellidoMDOC, placeholder: "Ingrese el apellido materno")

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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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

                    Button {
                        guardarPaciente()
                        guardarDoctor()
                        dismiss()
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nuevo Paciente")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func campoTexto(_ label: String, texto: Binding<String>, placeholder: String, teclado: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).fontWeight(.semibold)
            TextField(placeholder, text: texto)
                .keyboardType(teclado)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    func guardarPaciente() {
        let nuevo = Paciente(
            nombre: nombre, apellidoP: apellidoP, apellidoM: apellidoM,
            genero: genero, edad: Int(edad) ?? 0, fechaNac: fechaNacimiento,
            familiares: Int(familiares) ?? 0, curp: curp
        )
        nuevo.firmaPrivacidad = firmaPrivacidad
        modelContext.insert(nuevo)
        try? modelContext.save()
    }

    func guardarDoctor() {
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

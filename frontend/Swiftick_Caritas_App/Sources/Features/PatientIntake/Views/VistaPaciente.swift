//
//  VistaPaciente.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 13/05/26.
//

import SwiftUI

struct VistaPaciente: View {
    var paciente: Paciente
    @State var cambiarPantalla = false

    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(paciente.nombre) \(paciente.apellidoP) \(paciente.apellidoM)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("CURP: \(paciente.curp)")
                        .font(.footnote)
                    HStack {
                        Text("Género: \(paciente.genero)")
                            .font(.footnote)
                            .padding(5)
                            .background(Color(red: 136/255, green: 139/255, blue: 141/255).opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text("Edad: \(paciente.edad)")
                            .font(.footnote)
                            .padding(5)
                            .background(Color(red: 136/255, green: 139/255, blue: 141/255).opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text("Familiares: \(paciente.familiares)")
                            .font(.footnote)
                            .padding(5)
                            .background(Color(red: 136/255, green: 139/255, blue: 141/255).opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        cambiarPantalla = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color(red: 161/255, green: 90/255, blue: 149/255))
                        Text("Nueva Consulta")
                            .foregroundStyle(Color(red: 161/255, green: 90/255, blue: 149/255))
                    }
                    .padding(8)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .background(Color(red: 0/255, green: 156/255, blue: 166/255).opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("0")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Total de consultas")
                            .font(.subheadline)
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("0")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Servicios Recibidos")
                            .font(.subheadline)
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray))
                }

                VStack(alignment: .leading) {
                    Text("\nHistorial de consultas")
                        .font(.title)
                        .fontWeight(.bold)
                    LazyVStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "person")
                                    .frame(maxWidth: 50)
                                VStack(alignment: .leading) {
                                    Text("[Servicio]")
                                        .font(.title2)
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text(Date.now, style: .date)
                                    }
                                    .padding(3)
                                    HStack {
                                        Image(systemName: "building")
                                        Text("[TBD]")
                                    }
                                    .padding(3)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text("Diagnóstico")
                                    .font(.headline)
                                Text("TBD")
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading) {
                                Text("Tratamiento")
                                    .font(.headline)
                                Text("TBD")
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading) {
                                Text("Observaciones")
                                    .font(.headline)
                                Text("TBD")
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack {
                                Image(systemName: "doc")
                                Text("[DoctorName]")
                            }
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Historial")
        .navigationDestination(isPresented: $cambiarPantalla) {
            NuevoPacienteView()
        }
    }
}

#Preview {
    NavigationStack {
        VistaPaciente(paciente: Paciente(
            nombre: "Renata", apellidoP: "Méndez", apellidoM: "Rodríguez",
            genero: "Femenino", edad: 20, fechaNac: Date.now, familiares: 2, curp: "")
        )
    }
    .modelContainer(for: [Paciente.self, Doctor.self], inMemory: true)
}

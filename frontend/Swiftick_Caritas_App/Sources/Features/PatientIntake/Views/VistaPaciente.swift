//
//  VistaPaciente.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct VistaPaciente: View {
    var paciente: Paciente
    @State private var cambiarPantalla = false

    @Query private var todasConsultas: [ConsultaLocal]
    @Query private var doctores: [Doctor]

    private var consultas: [ConsultaLocal] {
        todasConsultas.filter { $0.localPacienteID == paciente.pacienteID.uuidString }
    }

    private var serviciosUnicos: Int {
        Set(consultas.map { $0.tipoServicio }).count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header card
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

                // Stats
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(consultas.count)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Total de consultas")
                            .font(.subheadline)
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(serviciosUnicos)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Servicios Recibidos")
                            .font(.subheadline)
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.gray))
                }

                // Historial
                VStack(alignment: .leading, spacing: 12) {
                    Text("Historial de consultas")
                        .font(.title)
                        .fontWeight(.bold)

                    if consultas.isEmpty {
                        Text("Sin consultas registradas")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(consultas.sorted { $0.fechaServicio > $1.fechaServicio }) { consulta in
                                ConsultaCardView(consulta: consulta, doctores: doctores)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .padding()
        }
        .navigationTitle("Historial")
        .navigationDestination(isPresented: $cambiarPantalla) {
            NuevaConsultaView(paciente: paciente)
        }
    }
}

private struct ConsultaCardView: View {
    let consulta: ConsultaLocal
    let doctores: [Doctor]

    private var doctorNombre: String {
        if let doc = doctores.first(where: { $0.dbID == consulta.doctorID }) {
            return "\(doc.nombre) \(doc.apellidoP)"
        }
        return "Dr. ID \(consulta.doctorID)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "stethoscope")
                    .frame(maxWidth: 40)
                VStack(alignment: .leading) {
                    Text(consulta.tipoServicio)
                        .font(.title2)
                        .fontWeight(.semibold)
                    HStack {
                        Image(systemName: "calendar")
                        Text(consulta.fechaServicio, style: .date)
                    }
                    .padding(3)
                    HStack {
                        Image(systemName: "person.fill")
                        Text(consulta.tipoPaciente)
                    }
                    .padding(3)
                }
            }

            VStack(alignment: .leading) {
                Text("Diagnóstico")
                    .font(.headline)
                Text(consulta.diagnostico.isEmpty ? "—" : consulta.diagnostico)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack {
                Image(systemName: "doc.text")
                Text(doctorNombre)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))
    }
}

#Preview {
    NavigationStack {
        VistaPaciente(paciente: Paciente(
            nombre: "Renata", apellidoP: "Méndez", apellidoM: "Rodríguez",
            genero: "Femenino", edad: 20, fechaNac: Date.now, familiares: 2, curp: "")
        )
    }
    .modelContainer(for: [Paciente.self, Doctor.self, ConsultaLocal.self], inMemory: true)
}

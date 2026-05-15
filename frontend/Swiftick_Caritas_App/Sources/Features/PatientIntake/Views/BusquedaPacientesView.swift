//
//  BusquedaPacientesView.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 13/05/26.
//

import SwiftUI
import SwiftData

struct BusquedaPacientesView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Paciente.nombre, order: .forward)
    var pacientes: [Paciente]
    @State var busqueda = ""
    @State var cambiarPantalla = false

    var pacientesFiltrados: [Paciente] {
        if busqueda.isEmpty { return pacientes }
        return pacientes.filter { paciente in
            let nombreCompleto = "\(paciente.nombre) \(paciente.apellidoP) \(paciente.apellidoM)"
            return nombreCompleto.localizedCaseInsensitiveContains(busqueda)
        }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Buscar paciente", text: $busqueda)
                    .textFieldStyle(.roundedBorder)
                Button {
                    cambiarPantalla = true
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0/255, green: 156/255, blue: 166/255))
            }

            List {
                ForEach(pacientesFiltrados) { paciente in
                    NavigationLink {
                        VistaPaciente(paciente: paciente)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("\(paciente.nombre) \(paciente.apellidoP) \(paciente.apellidoM)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(paciente.curp)
                                .font(.subheadline)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $cambiarPantalla) {
            NuevoPacienteView()
        }
        .navigationTitle("Pacientes")
        .padding()
        .scrollContentBackground(.hidden)
        .task {
            await generarPacientes()
        }
    }

    func generarPacientes() async {
        if pacientes.isEmpty {
            let seedData: [(String, String, String, String, Int, Int, String)] = [
                ("Joaquin",         "Perez",    "Rosales",   "Masculino", 31, 4, "TEC00011123"),
                ("Maria",           "García",   "Ramirez",   "Femenino",  38, 6, ""),
                ("Gabriel",         "Espino",   "Sifuentes", "Masculino", 20, 3, "TEC12345678"),
                ("Leonel Francisco","Bailón",   "Sifuentes", "Masculino", 20, 5, "TEC87654321"),
                ("Carlos",          "Sánchez",  "Gutiérrez", "Masculino", 21, 4, "TEC244466666"),
            ]
            for (nombre, ap, am, genero, edad, fam, curp) in seedData {
                modelContext.insert(
                    Paciente(nombre: nombre, apellidoP: ap, apellidoM: am,
                             genero: genero, edad: edad, fechaNac: Date(),
                             familiares: fam, curp: curp)
                )
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack {
        BusquedaPacientesView()
    }
    .modelContainer(for: [Paciente.self, Doctor.self], inMemory: true)
}

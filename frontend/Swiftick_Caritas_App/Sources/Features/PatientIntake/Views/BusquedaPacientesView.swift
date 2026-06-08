//
//  BusquedaPacientesView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData

struct BusquedaPacientesView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var appState: AppState
    @StateObject private var patientVM = PatientIntakeViewModel()

    @Query(sort: \Paciente.nombre, order: .forward)
    var pacientes: [Paciente]

    @Query(filter: #Predicate<Paciente> { !$0.isSynced })
    private var unsyncedPacientes: [Paciente]

    @Query(filter: #Predicate<Doctor> { !$0.isSynced })
    private var unsyncedDoctores: [Doctor]

    @State var busqueda = ""
    @State private var irAgregarPaciente = false

    private var pendingCount: Int { unsyncedPacientes.count + unsyncedDoctores.count }

    var pacientesFiltrados: [Paciente] {
        if busqueda.isEmpty { return pacientes }
        let query = busqueda.lowercased()
        return pacientes.filter { paciente in
            let nombreCompleto = "\(paciente.nombre) \(paciente.apellidoP) \(paciente.apellidoM)".lowercased()
            return nombreCompleto.contains(query) || paciente.curp.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Buscar paciente", text: $busqueda)
                    .textFieldStyle(.roundedBorder)
                Button {
                    irAgregarPaciente = true
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
                    NavigationLink(value: paciente) {
                        VStack(alignment: .leading) {
                            Text("\(paciente.nombre) \(paciente.apellidoP) \(paciente.apellidoM)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            HStack {
                                Text(paciente.curp)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.gray)
                                if !paciente.isSynced {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Paciente.self) { paciente in
                VistaPaciente(paciente: paciente)
            }
            .navigationDestination(isPresented: $irAgregarPaciente) {
                NuevoPacienteView()
            }
        }
        .navigationTitle("Pacientes")
        .padding()
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ConnectivityStatusView(
                    appState: appState,
                    pendingCount: pendingCount,
                    onSync: {
                        Task {
                            await patientVM.syncAll(context: modelContext, appState: appState)
                        }
                    }
                )
            }
        }
        .task {
            await generarPacientes()
        }
    }

    func generarPacientes() async {
        if pacientes.isEmpty {
            let seedData: [(String, String, String, String, Int, Int, String)] = [
                ("Joaquin",          "Perez",    "Rosales",   "Masculino", 31, 4, "TEC00011123"),
                ("Maria",            "García",   "Ramirez",   "Femenino",  38, 6, ""),
                ("Gabriel",          "Espino",   "Sifuentes", "Masculino", 20, 3, "TEC12345678"),
                ("Leonel Francisco", "Bailón",   "Sifuentes", "Masculino", 20, 5, "TEC87654321"),
                ("Carlos",           "Sánchez",  "Gutiérrez", "Masculino", 21, 4, "TEC244466666"),
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
    .environmentObject(AppState())
}

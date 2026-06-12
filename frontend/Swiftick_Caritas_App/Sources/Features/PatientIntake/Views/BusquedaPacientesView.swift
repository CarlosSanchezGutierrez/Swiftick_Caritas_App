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

    @Query var allDoctores: [Doctor]

    @State var busqueda = ""
    @State private var irAgregarPaciente = false
    @State private var alertaBrigada = false

    private var pendingCount: Int {
        pacientes.filter { !$0.isSynced }.count + allDoctores.filter { !$0.isSynced }.count
    }

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
                    if appState.brigadaActiva == nil {
                        alertaBrigada = true
                    } else {
                        irAgregarPaciente = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0/255, green: 156/255, blue: 166/255))
                .alert("Sin brigada activa", isPresented: $alertaBrigada) {
                    Button("Entendido", role: .cancel) {}
                } message: {
                    Text("Selecciona una brigada activa en Brigadas antes de registrar pacientes.")
                }
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
        }
        .navigationDestination(isPresented: $irAgregarPaciente) {
            NuevoPacienteView(navegacionActiva: $irAgregarPaciente)
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
    }
}

#Preview {
    NavigationStack {
        BusquedaPacientesView()
    }
    .modelContainer(for: [Paciente.self, Doctor.self], inMemory: true)
    .environmentObject(AppState())
}

//
//  PatientIntakeViewModel.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData
import Combine

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

@MainActor
final class PatientIntakeViewModel: ObservableObject {

    private let baseURL = "http://10.14.255.99:8000"

    // Pushes all unsynced Pacientes and Doctors to the server.
    // domicilioID is a placeholder (1) until the address form is integrated.
    func syncAll(context: ModelContext, appState: AppState) async {
        guard !appState.isSyncing else { return }
        appState.isSyncing = true
        defer { appState.isSyncing = false }

        await syncDoctors(context: context)
        await syncPacientes(context: context)
        patchConsultaPacienteIDs(context: context)
        await syncConsultas(context: context)
    }

    func syncNewDoctor(_ doctor: Doctor, context: ModelContext) async {
        if await pushDoctor(doctor) {
            doctor.isSynced = true
            try? context.save()
        }
    }

    func syncConsultasOnly(context: ModelContext, appState: AppState) async {
        guard !appState.isSyncing else { return }
        appState.isSyncing = true
        defer { appState.isSyncing = false }
        patchConsultaPacienteIDs(context: context)
        await syncConsultas(context: context)
    }

    // MARK: - Private sync steps

    private func syncDoctors(context: ModelContext) async {
        guard let unsynced = try? context.fetch(
            FetchDescriptor<Doctor>(predicate: #Predicate { !$0.isSynced })
        ) else { return }

        for doctor in unsynced {
            if await pushDoctor(doctor) {
                doctor.isSynced = true
            }
        }
        try? context.save()
    }

    private func syncPacientes(context: ModelContext) async {
        guard let unsynced = try? context.fetch(
            FetchDescriptor<Paciente>(predicate: #Predicate { !$0.isSynced })
        ) else { return }

        for paciente in unsynced {
            if await pushPaciente(paciente) {
                paciente.isSynced = true
            }
        }
        try? context.save()
    }

    // MARK: - API calls

    private func pushDoctor(_ doctor: Doctor) async -> Bool {
        guard let url = URL(string: "\(baseURL)/doctores") else { return false }

        let body: [String: Any] = [
            "nombre": doctor.nombre,
            "apellidoP": doctor.apellidoP,
            "apellidoM": doctor.apellidoM,
            "genero": doctor.genero,
            "realizandoPrac": doctor.realizandoPrac,
            "fechaNac": DateFormatter.iso8601Full.string(from: doctor.fechaNac)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            if http.statusCode == 200 || http.statusCode == 201 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let id = json["id"] as? Int {
                    doctor.dbID = id
                }
                return true
            }
            return http.statusCode == 409
        } catch {
            return false
        }
    }

    private func pushPaciente(_ paciente: Paciente) async -> Bool {
        guard let url = URL(string: "\(baseURL)/pacientes") else { return false }

        let domicilioID = await createDomicilio(
            ciudadID: paciente.ciudadID,
            calle: paciente.calle,
            numCasa: Int(paciente.numCasa) ?? 0
        ) ?? 1

        let body: [String: Any] = [
            "nombre": paciente.nombre,
            "apellidoP": paciente.apellidoP,
            "apellidoM": paciente.apellidoM,
            "genero": paciente.genero,
            "edad": paciente.edad,
            "fechaNac": DateFormatter.iso8601Full.string(from: paciente.fechaNac),
            "curp": paciente.curp,
            "familiares": paciente.familiares,
            "firmaPriv": paciente.firmaPrivacidad,
            "domicilioID": domicilioID
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            if http.statusCode == 201 || http.statusCode == 409 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let id = json["id"] as? Int {
                    paciente.dbID = id
                }
                return true
            }
            return false
        } catch {
            return false
        }
    }

    // After syncPacientes gives patients real dbIDs, backfill any consulta
    // that was saved while the patient was still unsynced (pacienteID == 0).
    private func patchConsultaPacienteIDs(context: ModelContext) {
        guard let consultas = try? context.fetch(FetchDescriptor<ConsultaLocal>()),
              let pacientes = try? context.fetch(FetchDescriptor<Paciente>()) else { return }
        let map = Dictionary(uniqueKeysWithValues: pacientes.map { ($0.pacienteID.uuidString, $0.dbID) })
        var changed = false
        for c in consultas where !c.isSynced && c.pacienteID == 0 {
            if let dbID = map[c.localPacienteID], dbID > 0 {
                c.pacienteID = dbID
                changed = true
            }
        }
        if changed { try? context.save() }
    }

    private func syncConsultas(context: ModelContext) async {
        guard let unsynced = try? context.fetch(
            FetchDescriptor<ConsultaLocal>(predicate: #Predicate { !$0.isSynced })
        ) else { return }
        let vm = consultaVM()
        for consulta in unsynced where consulta.pacienteID > 0 && consulta.doctorID > 0 && consulta.brigadaID > 0 {
            if let id = await vm.addServicio(
                pacienteID: consulta.pacienteID,
                doctorID: consulta.doctorID,
                brigadaID: consulta.brigadaID,
                signosID: consulta.signosID,
                medicamentosID: consulta.medicamentosID,
                cantMedicina: consulta.cantMedicina,
                tipoServicio: consulta.tipoServicio,
                fechaServicio: consulta.fechaServicio,
                imss: consulta.imss,
                tipoPaciente: consulta.tipoPaciente
            ) {
                consulta.id = id
                consulta.isSynced = true
            }
        }
        try? context.save()
    }

    private func createDomicilio(ciudadID: Int, calle: String, numCasa: Int) async -> Int? {
        guard ciudadID > 0, let url = URL(string: "\(baseURL)/domicilio") else { return nil }
        let body: [String: Any] = ["ciudadID": ciudadID, "calle": calle, "numCasa": numCasa]
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = json["id"] as? Int { return id }
            return nil
        } catch { return nil }
    }
}

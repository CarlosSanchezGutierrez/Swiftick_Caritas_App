//
//  PatientIntakeViewModel.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData
import Combine

private extension DateFormatter {
    static let apiDate: DateFormatter = {
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
            "fechaNac": DateFormatter.apiDate.string(from: doctor.fechaNac)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            // 200/201 = created, 409 = duplicate (already on server — still mark synced)
            return http.statusCode == 200 || http.statusCode == 201 || http.statusCode == 409
        } catch {
            return false
        }
    }

    // NOTE: domicilioID is fixed at 1 as a placeholder until the address section
    // of the registration form is integrated with the API.
    private func pushPaciente(_ paciente: Paciente) async -> Bool {
        guard let url = URL(string: "\(baseURL)/pacientes") else { return false }

        let body: [String: Any] = [
            "nombre": paciente.nombre,
            "apellidoP": paciente.apellidoP,
            "apellidoM": paciente.apellidoM,
            "genero": paciente.genero,
            "edad": paciente.edad,
            "fechaNac": DateFormatter.apiDate.string(from: paciente.fechaNac),
            "curp": paciente.curp,
            "familiares": paciente.familiares,
            "firmaPriv": paciente.firmaPrivacidad,
            "domicilioID": 1
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            return http.statusCode == 201
        } catch {
            return false
        }
    }
}

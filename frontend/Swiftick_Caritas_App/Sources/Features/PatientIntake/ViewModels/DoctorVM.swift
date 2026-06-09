//
//  DoctorVM.swift
//  Swiftick_Caritas_App
//

import Foundation
import Combine
import SwiftUI
import SwiftData

class doctorVM: ObservableObject {

    let baseUrl = "http://10.14.255.99:8000/doctores"

    @MainActor
    func fetchDoctor(id: Int) async -> DoctorAPIResponse? {
        guard let url = URL(string: baseUrl + "/\(id)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            return try decoder.decode(DoctorAPIResponse.self, from: data)
        } catch {
            print("Error al obtener datos: \(error)")
            return nil
        }
    }

    @MainActor
    func addDoctor(
        nombre: String,
        apellidoP: String,
        apellidoM: String,
        genero: String,
        realizandoPrac: Bool,
        fechaNac: Date
    ) async -> DoctorAPIResponse? {
        guard let url = URL(string: baseUrl) else { return nil }

        let body = nuevoDoctor(
            nombre: nombre, apellidoP: apellidoP, apellidoM: apellidoM,
            genero: genero, realizandoPrac: realizandoPrac, fechaNac: fechaNac
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        guard let jsonData = try? encoder.encode(body) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return nil }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            switch http.statusCode {
            case 201, 409:
                return try? decoder.decode(DoctorAPIResponse.self, from: data)
            default:
                print("Error:", http.statusCode)
                return nil
            }
        } catch {
            print("Error al enviar datos:", error)
            return nil
        }
    }

    func createDoctor(
        context: ModelContext,
        nombre: String, apellidoP: String, apellidoM: String,
        genero: String, realizandoPrac: Bool, fechaNac: Date
    ) {
        let doctor = Doctor(
            nombre: nombre, apellidoP: apellidoP, apellidoM: apellidoM,
            genero: genero, fechaNac: fechaNac, realizandoPrac: realizandoPrac
        )
        doctor.isSynced = false
        context.insert(doctor)
        try? context.save()
    }

    @MainActor
    func updateDoctor(
        id: Int,
        nombre: String, apellidoP: String, apellidoM: String,
        genero: String, realizandoPrac: Bool, fechaNac: Date
    ) async {
        guard let url = URL(string: baseUrl + "/\(id)") else { return }

        let body = nuevoDoctor(
            nombre: nombre, apellidoP: apellidoP, apellidoM: apellidoM,
            genero: genero, realizandoPrac: realizandoPrac, fechaNac: fechaNac
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        guard let jsonData = try? encoder.encode(body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                print("Status:", http.statusCode)
            }
        } catch {
            print("Error al enviar datos: \(error)")
        }
    }
}

//
//  DomicilioVM.swift
//  Swiftick_Caritas_App
//

import Foundation
import Combine
import SwiftUI
import SwiftData

class domicilioVM: ObservableObject {
    @Published var isOffline = false
    @Published var domicilios: [Domicilio] = []

    let baseUrl = "http://10.14.255.99:8000/domicilio"

    @MainActor
    func fetchDomicilio(id: Int) async {
        guard let url = URL(string: "\(baseUrl)/\(id)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let domicilio = try JSONDecoder().decode(Domicilio.self, from: data)
            domicilios = [domicilio]
        } catch {
            print("Error al obtener domicilio: \(error)")
        }
    }

    @MainActor
    func addDomicilio(ciudadID: Int, calle: String, numCasa: Int) async -> Int? {
        guard let url = URL(string: baseUrl) else { return nil }

        let body = nuevoDomicilio(ciudadID: ciudadID, calle: calle, numCasa: numCasa)
        guard let jsonData = try? JSONEncoder().encode(body) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("Status:", (response as? HTTPURLResponse)?.statusCode ?? 0)
            let respuesta = try JSONDecoder().decode(RespuestaDomicilio.self, from: data)
            return respuesta.id
        } catch {
            print(error)
            return nil
        }
    }

    func storeDomicilio(context: ModelContext, calle: String, numCasa: Int, ciudad: ciudadLocal) -> domicilioLocal? {
        let local = domicilioLocal(calle: calle, numCasa: numCasa, isSynced: false)
        local.ciudad = ciudad
        context.insert(local)
        try? context.save()
        return local
    }

    @MainActor
    func updateDomicilio(id: Int, ciudadID: Int, calle: String, numCasa: Int) async {
        guard let url = URL(string: "\(baseUrl)/\(id)") else { return }

        let body = Domicilio(id: id, ciudadID: ciudadID, calle: calle, numCasa: numCasa)
        guard let jsonData = try? JSONEncoder().encode(body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                await fetchDomicilio(id: id)
            }
        } catch {
            print("Error al actualizar domicilio: \(error)")
        }
    }

    @MainActor
    func syncDomicilios(context: ModelContext) async {
        guard !isOffline else { return }
        do {
            let pendientes = try context.fetch(
                FetchDescriptor<domicilioLocal>(predicate: #Predicate { !$0.isSynced })
            )
            for domicilio in pendientes {
                guard let ciudadID = domicilio.ciudad?.id else { continue }
                guard let serverID = await addDomicilio(
                    ciudadID: ciudadID, calle: domicilio.calle, numCasa: domicilio.numCasa
                ) else { continue }
                domicilio.id = serverID
                domicilio.isSynced = true
            }
            try context.save()
        } catch {
            print(error)
        }
    }
}

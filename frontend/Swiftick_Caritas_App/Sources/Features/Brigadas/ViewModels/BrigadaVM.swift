//
//  BrigadaVM.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData
import Combine

class brigadaVM: ObservableObject {
    private let baseURL = "http://10.14.255.99:8000"

    func fetchBrigadas() async -> [BrigadaAPIResponse] {
        guard let url = URL(string: "\(baseURL)/brigadas") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([BrigadaAPIResponse].self, from: data)
        } catch { return [] }
    }

    func fetchBrigada(id: Int) async -> BrigadaAPIResponse? {
        guard let url = URL(string: "\(baseURL)/brigadas/\(id)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(BrigadaAPIResponse.self, from: data)
        } catch { return nil }
    }

    func addBrigada(doctorID: Int, serviciosDisp: String, fechaOp: Date,
                    municipioID: Int, ciudadID: Int, colonia: String? = nil) async -> Int? {
        guard let url = URL(string: "\(baseURL)/brigadas") else { return nil }
        let body = NuevaBrigadaAPI(
            doctorID: doctorID,
            serviciosDisp: serviciosDisp,
            fechaOp: DateFormatter.iso8601Full.string(from: fechaOp),
            municipioID: municipioID,
            ciudadID: ciudadID,
            colonia: colonia
        )
        do {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(body)
            let (data, _) = try await URLSession.shared.data(for: req)
            let resp = try JSONDecoder().decode(RespuestaBrigadaID.self, from: data)
            return resp.id
        } catch { return nil }
    }

    func storeBrigada(context: ModelContext, doctorID: Int, serviciosDisp: String,
                      fechaOp: Date, municipioID: Int, ciudadID: Int,
                      colonia: String? = nil) -> BrigadaLocal {
        let brigada = BrigadaLocal(
            doctorID: doctorID, serviciosDisp: serviciosDisp,
            fechaOp: fechaOp, municipioID: municipioID,
            ciudadID: ciudadID, colonia: colonia
        )
        context.insert(brigada)
        return brigada
    }

    func syncBrigadas(context: ModelContext) async {
        let descriptor = FetchDescriptor<BrigadaLocal>()
        guard let all = try? context.fetch(descriptor) else { return }
        for brigada in all.filter({ !$0.isSynced }) {
            if let id = await addBrigada(
                doctorID: brigada.doctorID,
                serviciosDisp: brigada.serviciosDisp,
                fechaOp: brigada.fechaOp,
                municipioID: brigada.municipioID,
                ciudadID: brigada.ciudadID,
                colonia: brigada.colonia
            ) {
                brigada.id = id
                brigada.isSynced = true
                try? context.save()
            }
        }
    }
}

private struct RespuestaBrigadaID: Codable {
    let id: Int
}

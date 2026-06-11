//
//  ConsultaVM.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData
import Combine

class consultaVM: ObservableObject {
    private let baseURL = "http://10.14.255.99:8000"

    // MARK: - Servicios

    func fetchServicios() async -> [ServicioAPIResponse] {
        guard let url = URL(string: "\(baseURL)/servicios") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([ServicioAPIResponse].self, from: data)
        } catch { return [] }
    }

    func addServicio(pacienteID: Int, doctorID: Int, brigadaID: Int,
                     signosID: Int, medicamentosID: Int, cantMedicina: Int,
                     tipoServicio: String, fechaServicio: Date,
                     imss: Bool, tipoPaciente: String) async -> Int? {
        guard let url = URL(string: "\(baseURL)/servicios") else { return nil }
        let body = NuevoServicioAPI(
            pacienteID: pacienteID, doctorID: doctorID, brigadaID: brigadaID,
            signosID: signosID, medicamentosID: medicamentosID,
            cantMedicina: cantMedicina, tipoServicio: tipoServicio,
            fechaServicio: DateFormatter.iso8601Full.string(from: fechaServicio),
            imss: imss, tipoPaciente: tipoPaciente
        )
        do {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(body)
            let (data, _) = try await URLSession.shared.data(for: req)
            let resp = try JSONDecoder().decode(RespuestaConsultaID.self, from: data)
            return resp.id
        } catch { return nil }
    }

    func storeConsulta(context: ModelContext, pacienteID: Int, doctorID: Int,
                       brigadaID: Int, cantMedicina: Int, tipoServicio: String,
                       fechaServicio: Date, imss: Bool, tipoPaciente: String,
                       diagnostico: String) -> ConsultaLocal {
        let consulta = ConsultaLocal(
            pacienteID: pacienteID, doctorID: doctorID, brigadaID: brigadaID,
            cantMedicina: cantMedicina, tipoServicio: tipoServicio,
            fechaServicio: fechaServicio, imss: imss,
            tipoPaciente: tipoPaciente, diagnostico: diagnostico
        )
        context.insert(consulta)
        return consulta
    }

    func syncConsultas(context: ModelContext) async {
        let descriptor = FetchDescriptor<ConsultaLocal>()
        guard let all = try? context.fetch(descriptor) else { return }
        for consulta in all.filter({ !$0.isSynced }) {
            if let id = await addServicio(
                pacienteID: consulta.pacienteID,
                doctorID: consulta.doctorID,
                brigadaID: consulta.brigadaID,
                signosID: consulta.signosID ?? 0,
                medicamentosID: consulta.medicamentosID ?? 0,
                cantMedicina: consulta.cantMedicina,
                tipoServicio: consulta.tipoServicio,
                fechaServicio: consulta.fechaServicio,
                imss: consulta.imss,
                tipoPaciente: consulta.tipoPaciente
            ) {
                consulta.id = id
                consulta.isSynced = true
                try? context.save()
            }
        }
    }

    // MARK: - Signos Físicos

    func addSignosFisicos(pacienteID: Int, peso: Double, talla: String,
                          perimAbdom: Double, presArterD: Double, presArterS: Double,
                          pulso: Double, frecCard: Double, frecResp: Double) async -> Int? {
        guard let url = URL(string: "\(baseURL)/signosfisicos") else { return nil }
        let body = NuevosSignosFisicosAPI(
            pacienteID: pacienteID, peso: peso, talla: talla,
            perimAbdom: perimAbdom, presArterD: presArterD, presArterS: presArterS,
            pulso: pulso, frecCard: frecCard, frecResp: frecResp
        )
        do {
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(body)
            let (data, _) = try await URLSession.shared.data(for: req)
            let resp = try JSONDecoder().decode(RespuestaConsultaID.self, from: data)
            return resp.id
        } catch { return nil }
    }

    func storeSignosFisicos(context: ModelContext, pacienteID: Int, peso: Double,
                            talla: String, perimAbdom: Double, presArterD: Double,
                            presArterS: Double, pulso: Double, frecCard: Double,
                            frecResp: Double) -> SignosFisicosLocal {
        let signos = SignosFisicosLocal(
            pacienteID: pacienteID, peso: peso, talla: talla,
            perimAbdom: perimAbdom, presArterD: presArterD, presArterS: presArterS,
            pulso: pulso, frecCard: frecCard, frecResp: frecResp
        )
        context.insert(signos)
        return signos
    }

    func syncSignosFisicos(context: ModelContext) async {
        let descriptor = FetchDescriptor<SignosFisicosLocal>()
        guard let all = try? context.fetch(descriptor) else { return }
        for signos in all.filter({ !$0.isSynced }) {
            if let id = await addSignosFisicos(
                pacienteID: signos.pacienteID, peso: signos.peso, talla: signos.talla,
                perimAbdom: signos.perimAbdom, presArterD: signos.presArterD,
                presArterS: signos.presArterS, pulso: signos.pulso,
                frecCard: signos.frecCard, frecResp: signos.frecResp
            ) {
                signos.id = id
                signos.isSynced = true
                try? context.save()
            }
        }
    }
}

private struct RespuestaConsultaID: Codable {
    let id: Int
}

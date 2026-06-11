//
//  ConsultaSD.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData

// MARK: - API Codable types

struct ServicioAPIResponse: Codable {
    let id: Int
    let pacienteID: Int
    let doctorID: Int
    let brigadaID: Int
    let signosID: Int
    let medicamentosID: Int
    let cantMedicina: Int
    let tipoServicio: String
    let fechaServicio: String
    let imss: Bool
    let tipoPaciente: String
}

struct NuevoServicioAPI: Codable {
    let pacienteID: Int
    let doctorID: Int
    let brigadaID: Int
    let signosID: Int
    let medicamentosID: Int
    let cantMedicina: Int
    let tipoServicio: String
    let fechaServicio: String
    let imss: Bool
    let tipoPaciente: String
}

struct SignosFisicosAPIResponse: Codable {
    let id: Int
    let pacienteID: Int
    let peso: Double
    let talla: String
    let perimAbdom: Double
    let presArterD: Double
    let presArterS: Double
    let pulso: Double
    let frecCard: Double
    let frecResp: Double
}

struct NuevosSignosFisicosAPI: Codable {
    let pacienteID: Int
    let peso: Double
    let talla: String
    let perimAbdom: Double
    let presArterD: Double
    let presArterS: Double
    let pulso: Double
    let frecCard: Double
    let frecResp: Double
}

// MARK: - SwiftData models

@Model
class ConsultaLocal {
    var id: Int?
    var pacienteID: Int
    var doctorID: Int
    var brigadaID: Int
    var signosID: Int?
    var medicamentosID: Int?
    var cantMedicina: Int
    var tipoServicio: String
    var fechaServicio: Date
    var imss: Bool
    var tipoPaciente: String
    var diagnostico: String
    var isSynced: Bool = false

    init(pacienteID: Int, doctorID: Int, brigadaID: Int,
         cantMedicina: Int, tipoServicio: String,
         fechaServicio: Date, imss: Bool, tipoPaciente: String,
         diagnostico: String) {
        self.pacienteID = pacienteID
        self.doctorID = doctorID
        self.brigadaID = brigadaID
        self.cantMedicina = cantMedicina
        self.tipoServicio = tipoServicio
        self.fechaServicio = fechaServicio
        self.imss = imss
        self.tipoPaciente = tipoPaciente
        self.diagnostico = diagnostico
    }
}

@Model
class SignosFisicosLocal {
    var id: Int?
    var pacienteID: Int
    var peso: Double
    var talla: String
    var perimAbdom: Double
    var presArterD: Double
    var presArterS: Double
    var pulso: Double
    var frecCard: Double
    var frecResp: Double
    var isSynced: Bool = false

    init(pacienteID: Int, peso: Double, talla: String,
         perimAbdom: Double, presArterD: Double, presArterS: Double,
         pulso: Double, frecCard: Double, frecResp: Double) {
        self.pacienteID = pacienteID
        self.peso = peso
        self.talla = talla
        self.perimAbdom = perimAbdom
        self.presArterD = presArterD
        self.presArterS = presArterS
        self.pulso = pulso
        self.frecCard = frecCard
        self.frecResp = frecResp
    }
}

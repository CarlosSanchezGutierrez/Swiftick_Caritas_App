//
//  BrigadaSD.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData

// MARK: - API Codable types

struct BrigadaAPIResponse: Codable {
    let id: Int
    let doctorID: Int
    let serviciosDisp: String
    let fechaOp: String
    let municipioID: Int
    let ciudadID: Int
    let colonia: String?
}

struct NuevaBrigadaAPI: Codable {
    let doctorID: Int
    let serviciosDisp: String
    let fechaOp: String
    let municipioID: Int
    let ciudadID: Int
    let colonia: String?
}

// MARK: - SwiftData model

@Model
class BrigadaLocal {
    var id: Int?
    var doctorID: Int
    var serviciosDisp: String
    var fechaOp: Date
    var municipioID: Int
    var ciudadID: Int
    var colonia: String?
    var isSynced: Bool = false

    init(doctorID: Int, serviciosDisp: String, fechaOp: Date,
         municipioID: Int, ciudadID: Int, colonia: String? = nil) {
        self.doctorID = doctorID
        self.serviciosDisp = serviciosDisp
        self.fechaOp = fechaOp
        self.municipioID = municipioID
        self.ciudadID = ciudadID
        self.colonia = colonia
    }
}

//
//  DomicilioSD.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData

@Model
class domicilioLocal {
    @Attribute(.unique) var localID: UUID = UUID()
    var id: Int?
    var calle: String
    var numCasa: Int
    var isSynced: Bool

    var ciudad: ciudadLocal?

    init(id: Int? = nil, calle: String, numCasa: Int, isSynced: Bool = false) {
        self.id = id
        self.calle = calle
        self.numCasa = numCasa
        self.isSynced = isSynced
    }
}

struct Domicilio: Codable {
    let id: Int
    let ciudadID: Int
    let calle: String
    let numCasa: Int
}

struct nuevoDomicilio: Codable {
    let ciudadID: Int
    let calle: String
    let numCasa: Int
}

struct RespuestaDomicilio: Codable {
    let mensaje: String
    let id: Int
}

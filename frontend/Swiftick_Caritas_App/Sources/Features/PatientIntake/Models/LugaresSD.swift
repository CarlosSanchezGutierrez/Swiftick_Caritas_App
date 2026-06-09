//
//  LugaresSD.swift
//  Swiftick_Caritas_App
//

import Foundation
import SwiftData

@Model
class paisLocal {
    @Attribute(.unique) var localID: UUID = UUID()
    var id: Int?
    var nombre: String
    var isSynced: Bool

    @Relationship(deleteRule: .cascade, inverse: \estadoLocal.pais)
    var estados: [estadoLocal]? = []

    init(id: Int? = nil, nombre: String, isSynced: Bool = true) {
        self.id = id
        self.nombre = nombre
        self.isSynced = isSynced
    }
}

@Model
class estadoLocal {
    @Attribute(.unique) var localID: UUID = UUID()
    var id: Int?
    var nombre: String
    var isSynced: Bool

    var pais: paisLocal?

    @Relationship(deleteRule: .cascade, inverse: \municipioLocal.estado)
    var municipios: [municipioLocal]? = []

    init(id: Int? = nil, nombre: String, isSynced: Bool = true) {
        self.id = id
        self.nombre = nombre
        self.isSynced = isSynced
    }
}

@Model
class municipioLocal {
    @Attribute(.unique) var localID: UUID = UUID()
    var id: Int?
    var nombre: String
    var isSynced: Bool

    var estado: estadoLocal?

    @Relationship(deleteRule: .cascade, inverse: \ciudadLocal.municipio)
    var ciudades: [ciudadLocal]? = []

    init(id: Int? = nil, nombre: String, isSynced: Bool = true) {
        self.id = id
        self.nombre = nombre
        self.isSynced = isSynced
    }
}

@Model
class ciudadLocal {
    @Attribute(.unique) var localID: UUID = UUID()
    var id: Int?
    var nombre: String
    var isSynced: Bool

    var municipio: municipioLocal?

    @Relationship(deleteRule: .cascade, inverse: \domicilioLocal.ciudad)
    var domicilios: [domicilioLocal]? = []

    init(id: Int? = nil, nombre: String, isSynced: Bool = true) {
        self.id = id
        self.nombre = nombre
        self.isSynced = isSynced
    }
}

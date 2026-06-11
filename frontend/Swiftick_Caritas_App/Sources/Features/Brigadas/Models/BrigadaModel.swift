//
//  BrigadaModel.swift
//  Swiftick_Caritas_App
//

import Foundation

struct Brigada: Identifiable {
    var id: UUID = UUID()
    var dbID: Int = 0
    var nombre: String = ""
    var tipo: String = ""
    var fecha: Date = Date()
    var ruta: String = ""
    var servicios: [String] = []

    var brigadeInfo: BrigadeInfo {
        BrigadeInfo(
            title: nombre,
            subtitle: "Brigada \(tipo)",
            route: "Ruta \(ruta)",
            dateString: fecha.formatted(date: .abbreviated, time: .omitted)
        )
    }
}

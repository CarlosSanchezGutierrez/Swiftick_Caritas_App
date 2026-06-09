//
//  BrigadaModel.swift
//  Swiftick_Caritas_App
//

import Foundation

struct Brigada: Identifiable {
    var id: UUID = UUID()
    var nombre: String = ""
    var tipo: String = ""
    var fecha: Date = Date()
    var ruta: String = ""
    var servicios: [String] = []
}

//
//  PacienteSD.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 13/05/26.
//

import Foundation
import SwiftData

@Model
class Paciente {
    var pacienteID = UUID()
    var nombre: String
    var apellidoP: String
    var apellidoM: String
    var genero: String
    var edad: Int
    var fechaNac: Date
    var curp: String
    var familiares: Int
    var firmaPrivacidad: Bool

    init(nombre: String, apellidoP: String, apellidoM: String, genero: String, edad: Int, fechaNac: Date, familiares: Int, curp: String) {
        self.nombre = nombre
        self.apellidoP = apellidoP
        self.apellidoM = apellidoM
        self.genero = genero
        self.edad = edad
        self.fechaNac = fechaNac
        self.familiares = familiares
        self.firmaPrivacidad = false
        self.curp = curp.isEmpty ? "Sin CURP" : curp
    }
}

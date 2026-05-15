//
//  DoctorSD.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 13/05/26.
//

import Foundation
import SwiftData

@Model
class Doctor {
    var doctorID = UUID()
    var nombre: String
    var apellidoP: String
    var apellidoM: String
    var genero: String
    var fechaNac: Date
    var realizandoPrac: Bool

    init(nombre: String, apellidoP: String, apellidoM: String, genero: String, fechaNac: Date, realizandoPrac: Bool) {
        self.nombre = nombre
        self.apellidoP = apellidoP
        self.apellidoM = apellidoM
        self.genero = genero
        self.fechaNac = fechaNac
        self.realizandoPrac = realizandoPrac
    }
}

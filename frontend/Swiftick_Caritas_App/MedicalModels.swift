//
//  MedicalModels.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 30/04/26.
//

import Foundation

//Data Models
struct BrigadeInfo {
    let title: String
    let subtitle: String
    let route: String
    let dateString: String
}

struct SummaryMetric: Identifiable {
    let id = UUID()
    let icon: String
    let number: String
    let title: String
}

//Hardcoded Mock Data
struct MockData {
    static let currentBrigade = BrigadeInfo(
        title: "San Bernabé",
        subtitle: "Brigada Médica Integral",
        route: "Ruta Norte",
        dateString: "Hoy"
    )
    
    static let summaryMetrics = [
        SummaryMetric(icon: "person.2", number: "2", title: "Pacientes"),
        SummaryMetric(icon: "list.clipboard", number: "2", title: "Consultas"),
        SummaryMetric(icon: "waveform.path.ecg", number: "2", title: "Servicios"),
        SummaryMetric(icon: "mappin", number: "1", title: "Comunidades")
    ]
}

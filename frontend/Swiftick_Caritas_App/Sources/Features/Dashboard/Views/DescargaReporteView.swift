//
//  DescargaReporteView.swift
//  Swiftick_Caritas_App
//  Shared types used by the Descargar Reporte section in ContentView.
//

import SwiftUI

// MARK: - API response model

struct ReporteConsultaAPI: Codable {
    let id: Int
    let pacienteID: Int
    let pacienteNombre: String?
    let doctorID: Int
    let doctorNombre: String?
    let brigadaID: Int
    let brigadaColonia: String?
    let ciudadNombre: String?
    let signosID: Int?
    let cantMedicina: Int
    let tipoServicio: String
    let fechaServicio: String
    let imss: Int
    let tipoPaciente: String
}

// MARK: - Share sheet wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

//
//  ContentView.swift
//  Swiftick_Caritas_App
//

import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext
    @StateObject private var patientVM = PatientIntakeViewModel()

    // MARK: - Reporte state
    private let baseURL = "http://10.14.255.99:8000"
    @State private var reporteTipo   = ""
    @State private var reporteFiltro = ""
    @State private var reporteValor  = ""
    @State private var reporteIsLoading    = false
    @State private var reporteArchivoCSV: URL? = nil
    @State private var reporteMostrarShare = false
    @State private var reporteError: String? = nil

    private let opcionesPrincipal = ["Pacientes", "Doctores"]
    private var opcionesFiltro: [String] {
        reporteTipo == "Pacientes"
            ? ["Brigada", "Ciudad", "Servicio", "Doctor"]
            : ["Brigada", "Ciudad", "Servicio", "Pacientes"]
    }
    private var reporteListoParaDescargar: Bool {
        !reporteTipo.isEmpty &&
        !reporteFiltro.isEmpty &&
        !reporteValor.trimmingCharacters(in: .whitespaces).isEmpty &&
        !reporteIsLoading
    }

    private var currentBrigade: BrigadeInfo {
        appState.brigadaActiva?.brigadeInfo ?? MockData.currentBrigade
    }

    @Query private var allPacientes: [Paciente]
    @Query private var allDoctores: [Doctor]

    private var pendingCount: Int {
        allPacientes.filter { !$0.isSynced }.count + allDoctores.filter { !$0.isSynced }.count
    }

    private var summaryMetrics: [SummaryMetric] {
        [
            SummaryMetric(icon: "person.2",           number: "\(allPacientes.count)", title: "Pacientes"),
            SummaryMetric(icon: "list.clipboard",      number: "0",                    title: "Consultas"),
            SummaryMetric(icon: "waveform.path.ecg",   number: "0",                    title: "Servicios"),
            SummaryMetric(icon: "mappin",              number: "1",                    title: "Comunidades")
        ]
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 12) {
                        if UIImage(named: "logo") != nil {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                                .padding(.top, 10)
                        } else {
                            Text("Swiftick Caritas")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.teal)
                                .padding(.top, 10)
                        }

                        HStack {
                            Text("Sistema de Brigadas Médicas")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(AppTheme.textDark.opacity(0.8))
                            Spacer()
                            ConnectivityStatusView(
                                appState: appState,
                                pendingCount: pendingCount,
                                onSync: {
                                    Task {
                                        await patientVM.syncAll(context: modelContext, appState: appState)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    ActiveBrigadeCardView(info: currentBrigade)
                        .padding(.horizontal)

                    Text("Resumen")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textDark)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            SummaryCardView(metric: summaryMetrics[0])
                            SummaryCardView(metric: summaryMetrics[1])
                        }
                        HStack(spacing: 16) {
                            SummaryCardView(metric: summaryMetrics[2])
                            SummaryCardView(metric: summaryMetrics[3])
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Pacientes
                    NavigationLink(destination: BusquedaPacientesView()) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.teal.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.teal)
                            }
                            Text("Pacientes")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textDark)
                            Spacer()
                            if pendingCount > 0 {
                                Text("\(pendingCount)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color.orange)
                                    .clipShape(Capsule())
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)

                    // MARK: - Brigadas
                    NavigationLink(destination: ConfiguracionView()) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.teal.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "cross.case.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.teal)
                            }
                            Text("Brigadas")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textDark)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)

                    // MARK: - Descargar Reporte
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(AppTheme.teal)
                            Text("Descargar Reporte")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textDark)
                        }

                        HStack(spacing: 12) {
                            reportePickerCard(label: "Vista", selection: $reporteTipo, options: opcionesPrincipal)
                                .onChange(of: reporteTipo) {
                                    reporteFiltro = ""; reporteValor = ""; reporteError = nil
                                }
                            if !reporteTipo.isEmpty {
                                reportePickerCard(label: "Filtrar por", selection: $reporteFiltro, options: opcionesFiltro)
                                    .onChange(of: reporteFiltro) { reporteValor = ""; reporteError = nil }
                            }
                        }

                        if !reporteTipo.isEmpty && !reporteFiltro.isEmpty {
                            reporteSearchField(
                                icon: "line.3.horizontal.decrease",
                                placeholder: "Buscar \(reporteFiltro.lowercased())...",
                                text: $reporteValor
                            )
                        }

                        if let msg = reporteError {
                            Text(msg).font(.caption).foregroundColor(.red)
                        }

                        Button {
                            Task { await descargarReporte() }
                        } label: {
                            HStack(spacing: 8) {
                                if reporteIsLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "arrow.down.circle.fill").font(.title3)
                                }
                                Text(reporteIsLoading ? "Generando..." : "Descargar CSV").fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(reporteListoParaDescargar ? Color.blue : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!reporteListoParaDescargar)
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .sheet(isPresented: $reporteMostrarShare) {
                        if let url = reporteArchivoCSV { ShareSheet(items: [url]) }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Reporte network

    private func descargarReporte() async {
        reporteIsLoading = true
        reporteError     = nil
        defer { reporteIsLoading = false }

        var components = URLComponents(string: "\(baseURL)/reportes/consultas")!
        components.queryItems = [
            URLQueryItem(name: "tipo",   value: reporteTipo.lowercased()),
            URLQueryItem(name: "filtro", value: reporteFiltro.lowercased()),
            URLQueryItem(name: "valor",  value: reporteValor)
        ]
        guard let url = components.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let records = try JSONDecoder().decode([ReporteConsultaAPI].self, from: data)
            let fileURL = generarCSV(from: records)
            await MainActor.run {
                reporteArchivoCSV    = fileURL
                reporteMostrarShare  = fileURL != nil
            }
        } catch {
            await MainActor.run { reporteError = "Error al obtener datos del servidor." }
        }
    }

    private func generarCSV(from records: [ReporteConsultaAPI]) -> URL? {
        var csv = "id,pacienteID,pacienteNombre,doctorID,doctorNombre,brigadaID,brigadaColonia,ciudadNombre,signosID,cantMedicina,tipoServicio,fechaServicio,imss,tipoPaciente\n"
        for r in records {
            let row: [String] = [
                "\(r.id)", "\(r.pacienteID)",
                "\"\(r.pacienteNombre ?? "")\"",
                "\(r.doctorID)",
                "\"\(r.doctorNombre ?? "")\"",
                "\(r.brigadaID)",
                "\"\(r.brigadaColonia ?? "")\"",
                "\"\(r.ciudadNombre ?? "")\"",
                "\(r.signosID ?? 0)", "\(r.cantMedicina)",
                "\"\(r.tipoServicio)\"",
                r.fechaServicio,
                "\(r.imss)",
                "\"\(r.tipoPaciente)\""
            ]
            csv += row.joined(separator: ",") + "\n"
        }
        let fileName = "reporte_\(reporteTipo.lowercased())_\(Int(Date().timeIntervalSince1970)).csv"
        let fileURL  = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }

    // MARK: - Reporte subviews

    @ViewBuilder
    private func reportePickerCard(label: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption).foregroundColor(.secondary)
            Picker(label, selection: selection) {
                Text("Seleccionar").tag("")
                ForEach(options, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(UIColor.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func reporteSearchField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(.gray).frame(width: 18)
            TextField(placeholder, text: text)
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Paciente.self, Doctor.self], inMemory: true)
        .environmentObject(AppState())
}

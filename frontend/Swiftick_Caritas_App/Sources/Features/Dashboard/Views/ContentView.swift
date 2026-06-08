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

    let currentBrigade = MockData.currentBrigade

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
                    .padding(.bottom, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Paciente.self, Doctor.self], inMemory: true)
        .environmentObject(AppState())
}

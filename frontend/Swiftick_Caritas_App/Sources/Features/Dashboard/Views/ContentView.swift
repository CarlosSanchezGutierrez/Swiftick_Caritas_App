//
//  ContentView.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 23/04/26.
//

import SwiftUI

struct ContentView: View {
    // Fetching our hardcoded mock data
    let currentBrigade = MockData.currentBrigade
    let summaryMetrics = MockData.summaryMetrics

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 16) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .padding(.top, 10)

                        Text("Sistema de Brigadas Médicas")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textDark.opacity(0.8))
                    }
                    .padding(.horizontal)

                    Divider()

                    //Active Brigade Card Component
                    ActiveBrigadeCardView(info: currentBrigade)
                        .padding(.horizontal)

                    //Summary Section Title
                    Text("Resumen")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textDark)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    //Summary Grid Alternative
                    VStack(spacing: 16) {

                        // Top Row (Index 0 and 1)
                        HStack(spacing: 16) {
                            SummaryCardView(metric: summaryMetrics[0])
                            SummaryCardView(metric: summaryMetrics[1])
                        }

                        // Bottom Row (Index 2 and 3)
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
}

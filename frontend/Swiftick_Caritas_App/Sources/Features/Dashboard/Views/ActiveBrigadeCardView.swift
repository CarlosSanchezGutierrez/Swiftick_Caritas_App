//
//  ActiveBrigadeCardView.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 30/04/26.
//

import SwiftUI

struct ActiveBrigadeCardView: View {
    let info: BrigadeInfo?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(info != nil ? AppTheme.teal : Color(UIColor.systemGray3))

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 32, height: 32)
                            Image(systemName: info != nil ? "waveform.path.ecg" : "exclamationmark.triangle")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text(info != nil ? "BRIGADA ACTIVA" : "SIN BRIGADA ACTIVA")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Circle()
                        .fill(info != nil ? AppTheme.successGreen : Color.orange)
                        .frame(width: 8, height: 8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(info?.title ?? "No hay Brigada Activa")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    Text(info?.subtitle ?? "Selecciona una brigada desde Brigadas")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.95))
                }
                .padding(.top, 4)

                if let info {
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin")
                            Text(info.route)
                        }
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                            Text(info.dateString)
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                }
            }
            .padding(20)
        }
    }
}

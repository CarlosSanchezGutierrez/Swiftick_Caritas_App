//
//  ActiveBrigadeCardView.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 30/04/26.
//

import SwiftUI

struct ActiveBrigadeCardView: View {
    let info: BrigadeInfo

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.teal)

            VStack(alignment: .leading, spacing: 16) {
                //Top Row: Icon + Label + Indicator
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 32, height: 32)

                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("BRIGADA ACTIVA")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    //Green indicator dot
                    Circle()
                        .fill(AppTheme.successGreen)
                        .frame(width: 8, height: 8)
                }

                //Middle Row: Title and Subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text(info.subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.95))
                }
                .padding(.top, 4)

                //Bottom Row: Location and Date
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
            .padding(20)
        }
    }
}

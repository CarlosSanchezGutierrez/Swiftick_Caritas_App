//
//  SummaryCardView.swift
//  Swiftick_Caritas_App
//
//  Created by Alumno on 30/04/26.
//

import SwiftUI

struct SummaryCardView: View {
    let metric: SummaryMetric
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Circular Icon using ZStack
                ZStack {
                    Circle()
                        .fill(AppTheme.teal.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: metric.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppTheme.teal)
                }
                
                // Text Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.number)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.primary)
                    
                    Text(metric.title)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

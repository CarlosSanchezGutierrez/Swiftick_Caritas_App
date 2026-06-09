//
//  AppFonts.swift
//  Swiftick_Caritas_App
//

import SwiftUI

extension Font {
    static func gotham(_ weight: GothamWeight = .book, size: CGFloat) -> Font {
        .custom(weight.postscriptName, size: size)
    }

    enum GothamWeight {
        case thin, extraLight, light, book, medium, bold, black, ultra

        var postscriptName: String {
            switch self {
            case .thin:       return "Gotham Thin"
            case .extraLight: return "Gotham Extra Light"
            case .light:      return "Gotham Light"
            case .book:       return "Gotham Book"
            case .medium:     return "Gotham Medium"
            case .bold:       return "Gotham Bold"
            case .black:      return "Gotham Black"
            case .ultra:      return "Gotham Ultra"
            }
        }
    }
}

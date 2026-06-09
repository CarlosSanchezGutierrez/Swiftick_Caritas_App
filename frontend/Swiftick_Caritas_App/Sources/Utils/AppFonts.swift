//
//  AppFonts.swift
//  Swiftick_Caritas_App
//

import SwiftUI

extension Font {
    static func gotham(_ weight: GothamWeight = .regular, size: CGFloat) -> Font {
        .custom(weight.postscriptName, size: size)
    }

    enum GothamWeight {
        case thin, book, regular, medium, bold, black, ultra

        var postscriptName: String {
            switch self {
            case .thin:    return "Gotham Thin"
            case .book:    return "Gotham Book"
            case .regular: return "Gotham Regular"
            case .medium:  return "Gotham Medium"
            case .bold:    return "Gotham Bold"
            case .black:   return "Gotham Black"
            case .ultra:   return "Gotham Ultra"
            }
        }
    }
}

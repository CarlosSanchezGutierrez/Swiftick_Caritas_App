//
//  LugaresVM.swift
//  Swiftick_Caritas_App
//

import Foundation
import Combine
import SwiftUI
import SwiftData

class lugaresVM: ObservableObject {
    @Published var isOffline = false

    let baseUrl = "http://10.14.255.99:8000/"

    // Full refresh: delete local catalog and re-fetch from API.
    @MainActor
    func syncCatalogo(context: ModelContext) async {
        guard !isOffline else { return }

        do {
            try context.delete(model: ciudadLocal.self)
            try context.delete(model: municipioLocal.self)
            try context.delete(model: estadoLocal.self)
            try context.delete(model: paisLocal.self)
            try context.save()

            let catalogo = try await fetchCatalogo()

            var paisesMap: [Int: paisLocal] = [:]
            var estadosMap: [Int: estadoLocal] = [:]
            var municipiosMap: [Int: municipioLocal] = [:]

            for pais in catalogo.paises {
                let local = paisLocal(id: pais.id, nombre: pais.nombre, isSynced: true)
                context.insert(local)
                paisesMap[pais.id] = local
            }

            for estado in catalogo.estados {
                let local = estadoLocal(id: estado.id, nombre: estado.nombre, isSynced: true)
                local.pais = paisesMap[estado.paisID]
                context.insert(local)
                estadosMap[estado.id] = local
            }

            for municipio in catalogo.municipios {
                let local = municipioLocal(id: municipio.id, nombre: municipio.nombre, isSynced: true)
                local.estado = estadosMap[municipio.estadoID]
                context.insert(local)
                municipiosMap[municipio.id] = local
            }

            for ciudad in catalogo.ciudades {
                let local = ciudadLocal(id: ciudad.id, nombre: ciudad.nombre, isSynced: true)
                local.municipio = municipiosMap[ciudad.municipioID]
                context.insert(local)
            }

            try context.save()
        } catch {
            print("Error sincronizando catálogo: \(error)")
        }
    }

    func fetchCatalogo() async throws -> CatalogoSync {
        let url = URL(string: "\(baseUrl)catalogo")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(CatalogoSync.self, from: data)
    }

    // MARK: - Online CRUD

    @MainActor
    func addPais(nombre: String) async -> Pais? {
        guard let url = URL(string: baseUrl + "paises") else { return nil }
        let body = nuevoPais(nombre: nombre)
        guard let jsonData = try? JSONEncoder().encode(body) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 201 else { return nil }
            return try? JSONDecoder().decode(Pais.self, from: data)
        } catch {
            print("Error al enviar datos: \(error)"); return nil
        }
    }

    @MainActor
    func addEstado(paisID: Int, nombre: String) async -> Estado? {
        guard let url = URL(string: baseUrl + "estados") else { return nil }
        let body = nuevoEstado(paisID: paisID, nombre: nombre)
        guard let jsonData = try? JSONEncoder().encode(body) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 201 else { return nil }
            return try? JSONDecoder().decode(Estado.self, from: data)
        } catch {
            print("Error al enviar datos: \(error)"); return nil
        }
    }

    @MainActor
    func addMunicipio(estadoID: Int, nombre: String) async -> Municipio? {
        guard let url = URL(string: baseUrl + "municipios") else { return nil }
        let body = nuevoMunicipio(estadoID: estadoID, nombre: nombre)
        guard let jsonData = try? JSONEncoder().encode(body) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 201 else { return nil }
            return try? JSONDecoder().decode(Municipio.self, from: data)
        } catch {
            print("Error al enviar datos: \(error)"); return nil
        }
    }

    @MainActor
    func addCiudad(municipioID: Int, nombre: String) async -> Ciudad? {
        guard let url = URL(string: baseUrl + "ciudades") else { return nil }
        let body = nuevaCiudad(municipioID: municipioID, nombre: nombre)
        guard let jsonData = try? JSONEncoder().encode(body) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 201 else { return nil }
            return try? JSONDecoder().decode(Ciudad.self, from: data)
        } catch {
            print("Error al enviar datos: \(error)"); return nil
        }
    }

    // MARK: - Offline creation

    func crearPais(context: ModelContext, nombre: String) -> paisLocal? {
        let local = paisLocal(nombre: nombre, isSynced: false)
        context.insert(local)
        try? context.save()
        return local
    }

    func crearEstado(context: ModelContext, nombre: String, pais: paisLocal) -> estadoLocal? {
        let local = estadoLocal(nombre: nombre, isSynced: false)
        local.pais = pais
        context.insert(local)
        try? context.save()
        return local
    }

    func crearMunicipio(context: ModelContext, nombre: String, estado: estadoLocal) -> municipioLocal? {
        let local = municipioLocal(nombre: nombre, isSynced: false)
        local.estado = estado
        context.insert(local)
        try? context.save()
        return local
    }

    func crearCiudad(context: ModelContext, nombre: String, municipio: municipioLocal) -> ciudadLocal? {
        let local = ciudadLocal(nombre: nombre, isSynced: false)
        local.municipio = municipio
        context.insert(local)
        try? context.save()
        return local
    }

    // MARK: - Sync pending offline records

    @MainActor
    func syncPendientes(context: ModelContext) async {
        guard !isOffline else { return }

        do {
            let paises = try context.fetch(
                FetchDescriptor<paisLocal>(predicate: #Predicate { !$0.isSynced })
            )
            for pais in paises {
                guard let servidor = await addPais(nombre: pais.nombre) else { continue }
                pais.id = servidor.id
                pais.isSynced = true
            }
            try context.save()

            let estados = try context.fetch(
                FetchDescriptor<estadoLocal>(predicate: #Predicate { !$0.isSynced })
            )
            for estado in estados {
                guard let paisID = estado.pais?.id else { continue }
                guard let servidor = await addEstado(paisID: paisID, nombre: estado.nombre) else { continue }
                estado.id = servidor.id
                estado.isSynced = true
            }
            try context.save()

            let municipios = try context.fetch(
                FetchDescriptor<municipioLocal>(predicate: #Predicate { !$0.isSynced })
            )
            for municipio in municipios {
                guard let estadoID = municipio.estado?.id else { continue }
                guard let servidor = await addMunicipio(estadoID: estadoID, nombre: municipio.nombre) else { continue }
                municipio.id = servidor.id
                municipio.isSynced = true
            }
            try context.save()

            let ciudades = try context.fetch(
                FetchDescriptor<ciudadLocal>(predicate: #Predicate { !$0.isSynced })
            )
            for ciudad in ciudades {
                guard let municipioID = ciudad.municipio?.id else { continue }
                guard let servidor = await addCiudad(municipioID: municipioID, nombre: ciudad.nombre) else { continue }
                ciudad.id = servidor.id
                ciudad.isSynced = true
            }
            try context.save()

        } catch {
            print(error)
        }
    }
}

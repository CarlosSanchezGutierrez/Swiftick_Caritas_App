//
//  Swiftick_Caritas_AppTests.swift
//  Swiftick_Caritas_AppTests
//

import XCTest
import SwiftData
@testable import Swiftick_Caritas_App

// MARK: - Brigada model

final class BrigadaModelTests: XCTestCase {

    func testBrigadeInfoTitle() {
        let b = Brigada(nombre: "San Bernabé", tipo: "Médica", fecha: Date(), ruta: "Norte", servicios: [])
        XCTAssertEqual(b.brigadeInfo.title, "San Bernabé")
    }

    func testBrigadeInfoSubtitle() {
        let b = Brigada(nombre: "X", tipo: "Integral", fecha: Date(), ruta: "Sur", servicios: [])
        XCTAssertEqual(b.brigadeInfo.subtitle, "Brigada Integral")
    }

    func testBrigadeInfoRoute() {
        let b = Brigada(nombre: "X", tipo: "X", fecha: Date(), ruta: "Norte", servicios: [])
        XCTAssertEqual(b.brigadeInfo.route, "Ruta Norte")
    }

    func testNewBrigadaStartsWithZeroDBID() {
        let b = Brigada()
        XCTAssertEqual(b.dbID, 0)
    }
}

// MARK: - ConsultaLocal (SwiftData in-memory)

@MainActor
final class ConsultaLocalTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() async throws {
        container = try ModelContainer(
            for: ConsultaLocal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    override func tearDown() async throws {
        container = nil
    }

    func testInsertAndFetch() throws {
        let consulta = makeConsulta(tipoServicio: "Optometría", brigadaID: 5)
        context.insert(consulta)
        try context.save()

        let all = try context.fetch(FetchDescriptor<ConsultaLocal>())
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all[0].tipoServicio, "Optometría")
    }

    func testIsNotSyncedByDefault() {
        let consulta = makeConsulta()
        XCTAssertFalse(consulta.isSynced)
    }

    func testConsultasWithZeroBrigadaIDAreFilteredBySyncGuard() throws {
        // Mirrors the guard in PatientIntakeViewModel.syncConsultas
        context.insert(makeConsulta(brigadaID: 0))
        context.insert(makeConsulta(brigadaID: 0))
        context.insert(makeConsulta(brigadaID: 7))
        try context.save()

        let all = try context.fetch(FetchDescriptor<ConsultaLocal>())
        let eligible = all.filter { $0.pacienteID > 0 && $0.doctorID > 0 && $0.brigadaID > 0 }
        XCTAssertEqual(eligible.count, 1)
    }

    func testUniqueServiciosCount() throws {
        context.insert(makeConsulta(tipoServicio: "Optometría"))
        context.insert(makeConsulta(tipoServicio: "Optometría"))
        context.insert(makeConsulta(tipoServicio: "Consulta General"))
        try context.save()

        let all = try context.fetch(FetchDescriptor<ConsultaLocal>())
        let uniqueCount = Set(all.map { $0.tipoServicio }).count
        XCTAssertEqual(uniqueCount, 2)
    }

    // MARK: Helper
    private func makeConsulta(tipoServicio: String = "General",
                               pacienteID: Int = 1,
                               doctorID: Int = 1,
                               brigadaID: Int = 1) -> ConsultaLocal {
        ConsultaLocal(
            pacienteID: pacienteID,
            localPacienteID: UUID().uuidString,
            doctorID: doctorID,
            brigadaID: brigadaID,
            cantMedicina: 0,
            tipoServicio: tipoServicio,
            fechaServicio: Date(),
            imss: false,
            tipoPaciente: "General",
            diagnostico: ""
        )
    }
}

// MARK: - NuevoServicioAPI encoding

final class NuevoServicioAPIEncodingTests: XCTestCase {

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func testOptionalSignosIDEncodesAsNull() throws {
        let body = NuevoServicioAPI(
            pacienteID: 1, doctorID: 2, brigadaID: 3,
            signosID: nil, medicamentosID: nil,
            cantMedicina: 0, tipoServicio: "General",
            fechaServicio: "2026-06-12",
            imss: false, tipoPaciente: "General"
        )
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        // nil optionals encode as NSNull, not absent keys
        XCTAssertTrue(json["signosID"] is NSNull)
        XCTAssertTrue(json["medicamentosID"] is NSNull)
    }

    func testOptionalSignosIDEncodesValue() throws {
        let body = NuevoServicioAPI(
            pacienteID: 1, doctorID: 2, brigadaID: 3,
            signosID: 99, medicamentosID: 42,
            cantMedicina: 0, tipoServicio: "General",
            fechaServicio: "2026-06-12",
            imss: false, tipoPaciente: "General"
        )
        let data = try encoder.encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["signosID"] as? Int, 99)
        XCTAssertEqual(json["medicamentosID"] as? Int, 42)
    }
}

// MARK: - BrigadaLocal (SwiftData in-memory)

@MainActor
final class BrigadaLocalTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() async throws {
        container = try ModelContainer(
            for: BrigadaLocal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    override func tearDown() async throws {
        container = nil
    }

    func testComunidadesCountDeduplicatesColonia() throws {
        context.insert(BrigadaLocal(doctorID: 1, serviciosDisp: 1, fechaOp: Date(), municipioID: 1, ciudadID: 1, colonia: "San Bernabé"))
        context.insert(BrigadaLocal(doctorID: 1, serviciosDisp: 1, fechaOp: Date(), municipioID: 1, ciudadID: 1, colonia: "San Bernabé"))
        context.insert(BrigadaLocal(doctorID: 1, serviciosDisp: 1, fechaOp: Date(), municipioID: 1, ciudadID: 1, colonia: "Obispado"))
        try context.save()

        let all = try context.fetch(FetchDescriptor<BrigadaLocal>())
        let comunidades = Set(all.compactMap { $0.colonia }).count
        XCTAssertEqual(comunidades, 2)
    }

    func testBrigadaLocalIsNotSyncedByDefault() {
        let b = BrigadaLocal(doctorID: 1, serviciosDisp: 2, fechaOp: Date(), municipioID: 1, ciudadID: 1)
        XCTAssertFalse(b.isSynced)
    }
}

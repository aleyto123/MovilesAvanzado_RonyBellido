import Foundation
import XCTest
@testable import BoletaCore

final class BoletaTests: XCTestCase {
    func d(_ text: String) -> Decimal { Decimal(string: text)! }

    func testCuatroCasosAlCentavo() throws {
        let entradas = [
            DatosBoleta(sueldo: 2500),
            DatosBoleta(sueldo: 1800, dias: 27, tieneHijos: true),
            DatosBoleta(sueldo: 3000, tieneHijos: true, sistema: .afp, horas25: 4, horas35: 4, adelanto: 200),
            DatosBoleta(sueldo: 4200, dias: 24, tieneHijos: true, sistema: .afp, horas25: 2, horas35: 2, adelanto: 100)
        ]
        // Remuneraciones, descuentos, neto y EsSalud independientes de la implementación.
        let esperados = [
            ["2500", "325", "2175", "225"],
            ["1743", "226.59", "1516.41", "156.87"],
            ["3253", "621.27", "2631.73", "292.77"],
            ["3574", "562.83", "3011.17", "321.66"]
        ]
        for (indice, datos) in entradas.enumerated() {
            let r = try Boleta().calcular(datos)
            XCTAssertEqual([r.totalRemuneraciones, r.totalDescuentos, r.neto, r.aportaciones[0].monto], esperados[indice].map(d), "Caso \(indice + 1)")
            XCTAssertEqual(r.remuneraciones.count, 4)
            XCTAssertEqual(r.descuentos.count, 5)
        }
    }

    func testRedondeoPorConceptoYHoraSinRedondeoPrevio() throws {
        let r = try Boleta().calcular(DatosBoleta(sueldo: 1234, dias: 1, tieneHijos: true, sistema: .afp, horas25: 1, horas35: 1))
        XCTAssertEqual(r.remuneraciones.map(\.monto), [d("41.13"), 123, d("6.43"), d("6.94")])
        XCTAssertEqual(d("1.005").centavos(), d("1.01"))
    }

    func testValidacionesYLimites() throws {
        for dias in [0, 31, -1] { XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, dias: dias))) }
        for sueldo: Decimal in [0, -1, .nan] { XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: sueldo))) }
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, horas25: -1)))
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, horas35: -1)))
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, adelanto: -1)))
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, sistema: .afp, afp: "Inválida")))
        XCTAssertNoThrow(try Boleta().calcular(DatosBoleta(sueldo: 2500, dias: 1)))
        XCTAssertEqual(try Formulario.numero(" 2500,50 ", campo: "Sueldo"), d("2500.50"))
        for texto in ["", "NaN", "1e3", "2,500.00", "-1", "1.234", "abc"] {
            XCTAssertThrowsError(try Formulario.numero(texto, campo: "Sueldo"))
        }
    }

    func testEsSaludNoReduceNetoYAdelantoPuedeSuperarlo() throws {
        let r = try Boleta().calcular(DatosBoleta(sueldo: 100, adelanto: 200))
        XCTAssertEqual(r.neto, -113)
        XCTAssertEqual(r.costoEmpleador, 109)
        XCTAssertEqual(r.descuentos[1].monto, 0)
    }

    func testTodasLasAFPYComparacionONP() throws {
        for nombre in Parametros.afps.keys {
            let r = try Boleta().calcular(DatosBoleta(sueldo: 3000, sistema: .afp, afp: nombre))
            XCTAssertEqual(r.descuentos[0].monto, 0)
            XCTAssertEqual(r.descuentos[1].monto, 300)
        }
        let r = try Boleta().calcular(DatosBoleta(sueldo: 3000, tieneHijos: true, horas25: 4, horas35: 4, adelanto: 200))
        XCTAssertEqual(r.neto, d("2630.11"))
    }
}

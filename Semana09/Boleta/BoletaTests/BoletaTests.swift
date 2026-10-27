import Foundation
import XCTest
#if canImport(Boleta)
@testable import Boleta
#endif

final class BoletaTests: XCTestCase {
    private func d(_ texto: String) -> Decimal { Decimal(string: texto)! }

    func testCuatroCasosDeLaGuia() throws {
        let entradas = [
            DatosBoleta(sueldo: 2500),
            DatosBoleta(sueldo: 1800, dias: 27, tieneHijos: true),
            DatosBoleta(sueldo: 3000, tieneHijos: true, sistema: .afp, horas25: 4, horas35: 4, adelanto: 200),
            DatosBoleta(sueldo: 4200, dias: 24, tieneHijos: true, sistema: .afp, horas25: 2, horas35: 2, adelanto: 100)
        ]
        // Cuatro casos de la actividad, apartado 7; importes al centavo.
        // El cuarto caso se resuelve con las mismas reglas de los anteriores.
        // Sueldo, asignación, HE25, HE35, remuneraciones, ONP, fondo, comisión,
        // seguro, adelanto, descuentos, neto, EsSalud y costo del empleador.
        let esperados = [
            ["2500", "0", "0", "0", "2500", "325", "0", "0", "0", "0", "325", "2175", "225", "2725"],
            ["1620", "123", "0", "0", "1743", "226.59", "0", "0", "0", "0", "226.59", "1516.41", "156.87", "1899.87"],
            ["3000", "123", "62.50", "67.50", "3253", "0", "325.30", "52.05", "43.92", "200", "621.27", "2631.73", "292.77", "3545.77"],
            ["3360", "123", "43.75", "47.25", "3574", "0", "357.40", "57.18", "48.25", "100", "562.83", "3011.17", "321.66", "3895.66"]
        ]
        for (indice, entrada) in entradas.enumerated() {
            let r = try Boleta().calcular(entrada)
            let valores = r.remuneraciones.map(\.monto) + [r.totalRemuneraciones]
                + r.descuentos.map(\.monto) + [r.totalDescuentos, r.neto, r.aportaciones[0].monto, r.costoEmpleador]
            XCTAssertEqual(valores, esperados[indice].map(d), "Caso \(indice + 1)")
        }
    }

    func testRedondeoPorConceptoSinRedondearLaHora() throws {
        let r = try Boleta().calcular(DatosBoleta(sueldo: 1234, dias: 1, tieneHijos: true,
                                                 sistema: .afp, horas25: 1, horas35: 1))
        XCTAssertEqual(r.remuneraciones.map(\.monto), [d("41.13"), 123, d("6.43"), d("6.94")])
        XCTAssertEqual(d("1.005").centavos(), d("1.01"))
    }

    func testFormularioRechazaTextoVaciosYDecimalesInvalidos() throws {
        XCTAssertEqual(try Formulario.numero(" 2500,50 ", campo: "Sueldo"), d("2500.50"))
        for texto in ["", "abc", "NaN", "1e3", "2,500.00", "1.234", "-1"] {
            XCTAssertThrowsError(try Formulario.numero(texto, campo: "Importe"), texto)
        }
        for dias in ["", "0", "31", "-1", "2.5", "abc"] {
            XCTAssertThrowsError(try Formulario.datos(sueldo: "2500", dias: dias, hijos: false,
                sistema: .onp, afp: "AFP Ejemplo", horas25: "0", horas35: "0", adelanto: "0"))
        }
        for campo in 0..<3 {
            var valores = ["0", "0", "0"]
            valores[campo] = "texto"
            XCTAssertThrowsError(try Formulario.datos(sueldo: "2500", dias: "30", hijos: false,
                sistema: .onp, afp: "AFP Ejemplo", horas25: valores[0], horas35: valores[1], adelanto: valores[2]))
        }
    }

    func testMotorValidaLimitesYAFP() throws {
        for dias in [0, 31, -1] {
            XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, dias: dias)))
        }
        for sueldo: Decimal in [0, -1, .nan, 100_000_001] {
            XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: sueldo)))
        }
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, horas25: -1)))
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, horas35: .nan)))
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, adelanto: -1)))
        XCTAssertThrowsError(try Boleta().calcular(DatosBoleta(sueldo: 2500, sistema: .afp, afp: "Desconocida")))
        XCTAssertNoThrow(try Boleta().calcular(DatosBoleta(sueldo: 2500, dias: 1)))
    }

    func testAFPEjemploYCuatroAFPSobreFlujo() throws {
        let netos = ["AFP Ejemplo": "2611.50", "Habitat (flujo)": "2614.80",
                     "Integra (flujo)": "2612.40", "Prima (flujo)": "2610.90", "Profuturo (flujo)": "2608.20"]
        for (nombre, neto) in netos {
            let r = try Boleta().calcular(DatosBoleta(sueldo: 3000, sistema: .afp, afp: nombre))
            XCTAssertEqual(r.descuentos[0].monto, 0)
            XCTAssertEqual(r.neto, d(neto), nombre)
        }
    }

    func testEsSaludNoEsDescuentoYAdelantoPuedeSuperarElSueldo() throws {
        let r = try Boleta().calcular(DatosBoleta(sueldo: 100, adelanto: 200))
        XCTAssertEqual(r.neto, -113)
        XCTAssertEqual(r.aportaciones[0].monto, 9)
        XCTAssertEqual(r.costoEmpleador, 109)
        XCTAssertEqual(r.descuentos.count, 5)
    }

    func testComparacionONPAFPYAsignacionSinProrrateo() throws {
        let onp = try Boleta().calcular(DatosBoleta(sueldo: 3000, tieneHijos: true, horas25: 4, horas35: 4, adelanto: 200))
        XCTAssertEqual(onp.neto, d("2630.11"))
        let completo = try Boleta().calcular(DatosBoleta(sueldo: 1800, tieneHijos: true))
        let incompleto = try Boleta().calcular(DatosBoleta(sueldo: 1800, dias: 27, tieneHijos: true))
        XCTAssertEqual(completo.neto, d("1673.01"))
        XCTAssertEqual(completo.neto - incompleto.neto, d("156.60"))
        XCTAssertEqual(incompleto.remuneraciones[1].monto, 123)
    }
}

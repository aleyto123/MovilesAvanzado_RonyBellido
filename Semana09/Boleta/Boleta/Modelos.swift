import Foundation

enum SistemaPension: String, CaseIterable {
    case onp = "ONP"
    case afp = "AFP"
}

struct TasasAFP {
    let fondo: Decimal
    let comision: Decimal
    let seguro: Decimal
}

enum Parametros {
    // Actividad de boleta de pago, sección 4. Consulta: 27/10/2026.
    // RMV: D.S. 015-2026-TR. Asignación: Ley 25129. ONP: D.L. 19990.
    // EsSalud: Ley 26790. Las bases de cálculo siguen la actividad.
    static let rmv: Decimal = 1230
    static let asignacion: Decimal = Decimal(string: "0.10")!
    static let onp: Decimal = Decimal(string: "0.13")!
    static let essalud: Decimal = Decimal(string: "0.09")!
    static let dias: Decimal = 30
    static let horas: Decimal = 8
    static let extra25: Decimal = Decimal(string: "1.25")!
    static let extra35: Decimal = Decimal(string: "1.35")!

    // AFP Ejemplo: tasas de prueba del documento.
    // Otras AFP: SBS, devengue octubre de 2026, comisión sobre flujo.
    // https://www.sbs.gob.pe/app/spp/empleadores/comisiones_spp/paginas/comision_prima.aspx
    static let afps: [String: TasasAFP] = [
        "AFP Ejemplo": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.016")!, seguro: Decimal(string: "0.0135")!),
        "Habitat (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.0147")!, seguro: Decimal(string: "0.0137")!),
        "Integra (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.0155")!, seguro: Decimal(string: "0.0137")!),
        "Prima (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.016")!, seguro: Decimal(string: "0.0137")!),
        "Profuturo (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.0169")!, seguro: Decimal(string: "0.0137")!)
    ]
}

struct DatosBoleta {
    var sueldo: Decimal
    var dias: Int
    var tieneHijos: Bool
    var sistema: SistemaPension
    var afp: String
    var horas25: Decimal
    var horas35: Decimal
    var adelanto: Decimal

    init(sueldo: Decimal, dias: Int = 30, tieneHijos: Bool = false,
         sistema: SistemaPension = .onp, afp: String = "AFP Ejemplo",
         horas25: Decimal = 0, horas35: Decimal = 0, adelanto: Decimal = 0) {
        self.sueldo = sueldo
        self.dias = dias
        self.tieneHijos = tieneHijos
        self.sistema = sistema
        self.afp = afp
        self.horas25 = horas25
        self.horas35 = horas35
        self.adelanto = adelanto
    }
}

struct Concepto: Identifiable {
    let nombre: String
    let monto: Decimal
    var id: String { nombre }
}

struct ResultadoBoleta {
    let remuneraciones: [Concepto]
    let descuentos: [Concepto]
    let aportaciones: [Concepto]

    var totalRemuneraciones: Decimal { remuneraciones.reduce(0) { $0 + $1.monto } }
    var totalDescuentos: Decimal { descuentos.reduce(0) { $0 + $1.monto } }
    var neto: Decimal { totalRemuneraciones - totalDescuentos }
    var costoEmpleador: Decimal { totalRemuneraciones + aportaciones.reduce(0) { $0 + $1.monto } }
}

extension Decimal {
    func centavos() -> Decimal {
        var original = self
        var resultado = Decimal()
        NSDecimalRound(&resultado, &original, 2, .plain)
        return resultado
    }

    var soles: String {
        let formato = NumberFormatter()
        formato.locale = Locale(identifier: "es_PE")
        formato.numberStyle = .currency
        formato.currencyCode = "PEN"
        formato.currencySymbol = "S/ "
        formato.minimumFractionDigits = 2
        formato.maximumFractionDigits = 2
        return formato.string(from: NSDecimalNumber(decimal: self)) ?? "S/ 0.00"
    }
}

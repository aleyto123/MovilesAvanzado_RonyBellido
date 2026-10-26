import Foundation

public enum SistemaPension: String, CaseIterable, Sendable { case onp = "ONP", afp = "AFP" }

public struct TasasAFP: Sendable {
    public let fondo: Decimal
    public let comision: Decimal
    public let seguro: Decimal
}

public enum Parametros {
    // Actividad Grupo B, consultada 26/10/2026. Valores centralizados.
    public static let rmv: Decimal = 1230
    public static let asignacion: Decimal = Decimal(string: "0.10")!
    public static let onp: Decimal = Decimal(string: "0.13")!
    public static let essalud: Decimal = Decimal(string: "0.09")!
    public static let dias: Decimal = 30
    public static let horas: Decimal = 8
    public static let extra25: Decimal = Decimal(string: "1.25")!
    public static let extra35: Decimal = Decimal(string: "1.35")!
    // SBS, devengue octubre 2026, comisión sobre flujo. No comisión sobre saldo.
    public static let afps: [String: TasasAFP] = [
        "AFP Ejemplo": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.016")!, seguro: Decimal(string: "0.0135")!),
        "Habitat (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.0147")!, seguro: Decimal(string: "0.0137")!),
        "Integra (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.0155")!, seguro: Decimal(string: "0.0137")!),
        "Prima (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.016")!, seguro: Decimal(string: "0.0137")!),
        "Profuturo (flujo)": TasasAFP(fondo: Decimal(string: "0.10")!, comision: Decimal(string: "0.0169")!, seguro: Decimal(string: "0.0137")!)
    ]
}

public struct DatosBoleta: Sendable {
    public var sueldo: Decimal
    public var dias: Int
    public var tieneHijos: Bool
    public var sistema: SistemaPension
    public var afp: String
    public var horas25: Decimal
    public var horas35: Decimal
    public var adelanto: Decimal

    public init(sueldo: Decimal, dias: Int = 30, tieneHijos: Bool = false,
                sistema: SistemaPension = .onp, afp: String = "AFP Ejemplo",
                horas25: Decimal = 0, horas35: Decimal = 0, adelanto: Decimal = 0) {
        self.sueldo = sueldo; self.dias = dias; self.tieneHijos = tieneHijos
        self.sistema = sistema; self.afp = afp
        self.horas25 = horas25; self.horas35 = horas35; self.adelanto = adelanto
    }
}

public struct Concepto: Identifiable, Sendable {
    public let nombre: String
    public let monto: Decimal
    public var id: String { nombre }
}

public struct ResultadoBoleta: Sendable {
    public let remuneraciones: [Concepto]
    public let descuentos: [Concepto]
    public let aportaciones: [Concepto]
    public var totalRemuneraciones: Decimal { remuneraciones.reduce(0) { $0 + $1.monto } }
    public var totalDescuentos: Decimal { descuentos.reduce(0) { $0 + $1.monto } }
    public var neto: Decimal { totalRemuneraciones - totalDescuentos }
    public var costoEmpleador: Decimal { totalRemuneraciones + aportaciones.reduce(0) { $0 + $1.monto } }
}

public extension Decimal {
    func centavos() -> Decimal {
        var original = self
        var redondeado = Decimal()
        NSDecimalRound(&redondeado, &original, 2, .plain)
        return redondeado
    }
    var soles: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.numberStyle = .currency
        formatter.currencyCode = "PEN"
        formatter.currencySymbol = "S/ "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "S/ 0.00"
    }
}

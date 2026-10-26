import Foundation

public struct ErrorBoleta: LocalizedError {
    public let mensaje: String
    public var errorDescription: String? { mensaje }
    public init(_ mensaje: String) { self.mensaje = mensaje }
}

public final class Boleta {
    public init() {}

    public func calcular(_ datos: DatosBoleta) throws -> ResultadoBoleta {
        guard !datos.sueldo.isNaN, datos.sueldo > 0, datos.sueldo <= 100_000_000 else {
            throw ErrorBoleta("El sueldo debe ser mayor que cero y no superar 100 millones.")
        }
        guard (1...30).contains(datos.dias) else { throw ErrorBoleta("Los días deben ser un entero entre 1 y 30.") }
        for (nombre, valor) in [("Horas al 25%", datos.horas25), ("Horas al 35%", datos.horas35), ("Adelantos", datos.adelanto)] {
            guard !valor.isNaN, valor >= 0, valor <= 100_000_000 else {
                throw ErrorBoleta("\(nombre): ingresa un número entre 0 y 100 millones.")
            }
        }
        let valorHora = datos.sueldo / Parametros.dias / Parametros.horas
        let remuneraciones = [
            Concepto(nombre: "Sueldo computable", monto: (datos.sueldo / Parametros.dias * Decimal(datos.dias)).centavos()),
            Concepto(nombre: "Asignación familiar", monto: datos.tieneHijos ? (Parametros.rmv * Parametros.asignacion).centavos() : 0),
            Concepto(nombre: "Horas extras 25%", monto: (valorHora * Parametros.extra25 * datos.horas25).centavos()),
            Concepto(nombre: "Horas extras 35%", monto: (valorHora * Parametros.extra35 * datos.horas35).centavos())
        ]
        let total = remuneraciones.reduce(Decimal.zero) { $0 + $1.monto }
        var pensionONP: Decimal = 0
        var fondo: Decimal = 0
        var comision: Decimal = 0
        var seguro: Decimal = 0
        if datos.sistema == .onp {
            pensionONP = (total * Parametros.onp).centavos()
        } else {
            guard let tasas = Parametros.afps[datos.afp] else { throw ErrorBoleta("Selecciona una AFP válida.") }
            fondo = (total * tasas.fondo).centavos()
            comision = (total * tasas.comision).centavos()
            seguro = (total * tasas.seguro).centavos()
        }
        let descuentos = [
            Concepto(nombre: "ONP", monto: pensionONP),
            Concepto(nombre: "AFP fondo", monto: fondo),
            Concepto(nombre: "AFP comisión", monto: comision),
            Concepto(nombre: "AFP seguro", monto: seguro),
            Concepto(nombre: "Adelantos", monto: datos.adelanto.centavos())
        ]
        return ResultadoBoleta(remuneraciones: remuneraciones, descuentos: descuentos,
            aportaciones: [Concepto(nombre: "EsSalud (9%)", monto: (total * Parametros.essalud).centavos())])
    }
}

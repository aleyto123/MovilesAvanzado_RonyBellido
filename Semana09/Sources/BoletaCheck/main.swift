import Foundation
import BoletaCore

let casos = [
    DatosBoleta(sueldo: 2500),
    DatosBoleta(sueldo: 1800, dias: 27, tieneHijos: true),
    DatosBoleta(sueldo: 3000, tieneHijos: true, sistema: .afp, horas25: 4, horas35: 4, adelanto: 200),
    DatosBoleta(sueldo: 4200, dias: 24, tieneHijos: true, sistema: .afp, horas25: 2, horas35: 2, adelanto: 100),
    DatosBoleta(sueldo: 2300, sistema: .afp, afp: "Prima (flujo)")
]
let filas = try casos.map { datos -> [String: String] in
    let r = try Boleta().calcular(datos)
    var fila: [String: String] = [:]
    for (indice, concepto) in r.remuneraciones.enumerated() {
        fila[String(13 + indice)] = NSDecimalNumber(decimal: concepto.monto).stringValue
    }
    for (indice, concepto) in r.descuentos.enumerated() {
        fila[String(19 + indice)] = NSDecimalNumber(decimal: concepto.monto).stringValue
    }
    for (numero, monto) in [(17, r.totalRemuneraciones), (24, r.totalDescuentos),
                           (26, r.neto), (27, r.aportaciones[0].monto), (28, r.costoEmpleador)] {
        fila[String(numero)] = NSDecimalNumber(decimal: monto).stringValue
    }
    return fila
}
let salida = try JSONSerialization.data(withJSONObject: filas, options: [.prettyPrinted, .sortedKeys])
if CommandLine.arguments.count > 1 {
    try salida.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
} else { print(String(decoding: salida, as: UTF8.self)) }

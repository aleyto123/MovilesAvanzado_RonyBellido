import Foundation

public enum Formulario {
    // No se admiten separadores de miles: evita interpretar 2,500 como 2500.
    public static func numero(_ texto: String, campo: String, decimales: Int = 2) throws -> Decimal {
        let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        let patron = "^[0-9]+([.,][0-9]{1,\(decimales)})?$"
        guard limpio.range(of: patron, options: .regularExpression) != nil,
              let numero = Decimal(string: limpio.replacingOccurrences(of: ",", with: "."), locale: Locale(identifier: "en_US_POSIX")),
              !numero.isNaN else {
            throw ErrorBoleta("\(campo): ingresa un número sin miles, con hasta \(decimales) decimales. Ejemplo: 2500,50.")
        }
        return numero
    }

    public static func datos(sueldo: String, dias: String, hijos: Bool, sistema: SistemaPension,
                             afp: String, horas25: String, horas35: String, adelanto: String) throws -> DatosBoleta {
        let textoDias = dias.trimmingCharacters(in: .whitespacesAndNewlines)
        guard textoDias.range(of: "^[0-9]{1,2}$", options: .regularExpression) != nil,
              let diasValor = Int(textoDias), (1...30).contains(diasValor) else {
            throw ErrorBoleta("Días laborados: ingresa un entero entre 1 y 30.")
        }
        return DatosBoleta(sueldo: try numero(sueldo, campo: "Sueldo básico"), dias: diasValor,
            tieneHijos: hijos, sistema: sistema, afp: afp,
            horas25: try numero(horas25, campo: "Horas al 25%"),
            horas35: try numero(horas35, campo: "Horas al 35%"),
            adelanto: try numero(adelanto, campo: "Adelantos"))
    }
}

import Foundation

enum Formulario {
    static func numero(_ texto: String, campo: String) throws -> Decimal {
        let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard limpio.range(of: "^[0-9]+([.,][0-9]{1,2})?$", options: .regularExpression) != nil,
              let valor = Decimal(string: limpio.replacingOccurrences(of: ",", with: "."), locale: Locale(identifier: "en_US_POSIX")),
              !valor.isNaN else {
            throw ErrorBoleta("\(campo): ingresa un número sin separador de miles y con hasta dos decimales.")
        }
        return valor
    }

    static func datos(sueldo: String, dias: String, hijos: Bool, sistema: SistemaPension,
                      afp: String, horas25: String, horas35: String, adelanto: String) throws -> DatosBoleta {
        let sueldoValor = try numero(sueldo, campo: "Sueldo básico")
        let textoDias = dias.trimmingCharacters(in: .whitespacesAndNewlines)
        guard textoDias.range(of: "^[0-9]{1,2}$", options: .regularExpression) != nil,
              let diasValor = Int(textoDias), (1...30).contains(diasValor) else {
            throw ErrorBoleta("Días laborados: ingresa un entero entre 1 y 30.")
        }
        return DatosBoleta(sueldo: sueldoValor, dias: diasValor, tieneHijos: hijos, sistema: sistema,
                           afp: afp, horas25: try numero(horas25, campo: "Horas al 25%"),
                           horas35: try numero(horas35, campo: "Horas al 35%"),
                           adelanto: try numero(adelanto, campo: "Adelantos"))
    }
}

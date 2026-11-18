import Foundation

enum EstadoCompra: String, CaseIterable {
    case pendiente = "Pendiente"
    case aprobada = "Aprobada"
    case rechazada = "Rechazada"
}

struct ImporteCompra {
    let subtotal: Decimal
    let igv: Decimal
    let total: Decimal

    var requiereAprobacion: Bool { total >= 5_000 }

    init(costo: Decimal, cantidad: Int) {
        subtotal = (costo * Decimal(cantidad)).redondeadoAMoneda
        igv = (subtotal * 18 / 100).redondeadoAMoneda
        total = subtotal + igv
    }
}

struct EfectoInventario {
    let stock: Int
    let costoPromedio: Decimal

    init?(stockActual: Int, costoActual: Decimal, cantidad: Int, costoUnitario: Decimal) {
        let (nuevoStock, desbordamiento) = stockActual.addingReportingOverflow(cantidad)
        guard stockActual >= 0, cantidad > 0, !desbordamiento else { return nil }

        stock = nuevoStock
        let valor = Decimal(stockActual) * costoActual + Decimal(cantidad) * costoUnitario
        costoPromedio = (valor / Decimal(nuevoStock)).redondeadoAMoneda
    }
}

extension Decimal {
    var redondeadoAMoneda: Decimal {
        var origen = self
        var resultado = Decimal()
        NSDecimalRound(&resultado, &origen, 2, .plain)
        return resultado
    }

    var soles: String { formatted(.currency(code: "PEN").locale(Locale(identifier: "es_PE"))) }
}

extension Double {
    var soles: String { Decimal(self).soles }
}

extension String {
    var recortado: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    var iniciales: String {
        let palabras = split { !$0.isLetter }
        guard let primera = palabras.first else { return "?" }
        if palabras.count == 1 { return String(primera.prefix(2)).uppercased() }
        return String(palabras.prefix(2).compactMap(\.first)).uppercased()
    }

    var esRUC: Bool {
        recortado.range(of: #"^[0-9]{11}$"#, options: .regularExpression) != nil
    }

    var unidades: Int? {
        let texto = recortado
        guard texto.range(of: #"^[0-9]+$"#, options: .regularExpression) != nil else { return nil }
        return Int(texto)
    }

    var importeMonetario: Decimal? {
        let texto = recortado
        guard texto.range(of: #"^[0-9]+([.,][0-9]{1,2})?$"#, options: .regularExpression) != nil else { return nil }
        return Decimal(string: texto.replacingOccurrences(of: ",", with: "."), locale: Locale(identifier: "en_US_POSIX"))
    }
}

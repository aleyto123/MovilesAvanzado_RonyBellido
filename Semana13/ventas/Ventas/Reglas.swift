import Foundation

enum CategoriaCliente: String {
    case regular = "Regular"
    case frecuente = "Frecuente"
    case vip = "VIP"

    init(total: Decimal) {
        if total >= 5_000 {
            self = .vip
        } else if total >= 1_000 {
            self = .frecuente
        } else {
            self = .regular
        }
    }
}

struct ImporteVenta {
    let subtotal: Decimal
    let descuento: Decimal
    let igv: Decimal
    let total: Decimal

    init(precio: Decimal, cantidad: Int, categoria: CategoriaCliente) {
        subtotal = Self.redondear(precio * Decimal(cantidad))
        descuento = categoria == .vip ? Self.redondear(subtotal / 10) : 0
        let base = subtotal - descuento
        igv = Self.redondear(base * 18 / 100)
        total = base + igv
    }

    static func redondear(_ valor: Decimal) -> Decimal {
        var origen = valor
        var resultado = Decimal()
        NSDecimalRound(&resultado, &origen, 2, .plain)
        return resultado
    }
}

extension Decimal {
    var soles: String { formatted(.currency(code: "PEN").locale(Locale(identifier: "es_PE"))) }
}

extension Double {
    var soles: String { Decimal(self).soles }
}

extension String {
    var recortado: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

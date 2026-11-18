import Foundation

enum TipoDocumento: String, CaseIterable, Identifiable, Codable {
    case dni = "DNI"
    case ruc = "RUC"
    case carnetExtranjeria = "Carné de extranjería"
    case pasaporte = "Pasaporte"

    var id: String { rawValue }

    var indicacion: String {
        switch self {
        case .dni: "El DNI debe contener 8 dígitos."
        case .ruc: "El RUC debe contener 11 dígitos."
        case .carnetExtranjeria, .pasaporte: "Ingresa de 1 a 12 letras, dígitos o guiones."
        }
    }

    func admite(_ numero: String) -> Bool {
        let patron: String
        switch self {
        case .dni: patron = #"^[0-9]{8}$"#
        case .ruc: patron = #"^[0-9]{11}$"#
        case .carnetExtranjeria, .pasaporte: patron = #"^[A-Z0-9-]{1,12}$"#
        }
        return numero.documentoNormalizado.range(of: patron, options: .regularExpression) != nil
    }

    static func inferir(_ numero: String) -> TipoDocumento? {
        if TipoDocumento.dni.admite(numero) { return .dni }
        if TipoDocumento.ruc.admite(numero) { return .ruc }
        return nil
    }
}

struct ComprobanteDemostracion: Codable {
    let numero: Int
    let fechaEmision: Date
    let fechaVenta: Date
    let cliente: String
    let tipoDocumento: TipoDocumento
    let documento: String
    let vendedor: String
    let producto: String
    let cantidad: Int
    let precioUnitario: Decimal
    let descuento: Decimal
    let igv: Decimal
    let total: Decimal

    var identificador: String {
        let digitos = String(numero)
        let ceros = String(repeating: "0", count: max(0, 6 - digitos.count))
        return "DEMO-\(ceros)\(digitos)"
    }

    var subtotal: Decimal {
        ImporteVenta.redondear(precioUnitario * Decimal(cantidad))
    }

    var problemaValidacion: String? {
        guard numero > 0 else { return "El número de demostración debe ser positivo." }
        guard !cliente.recortado.isEmpty, tipoDocumento.admite(documento) else {
            return "Completa los nombres y el documento del cliente."
        }
        guard cantidad > 0, precioUnitario > 0, descuento >= 0, descuento <= subtotal else {
            return "La cantidad o los importes de la venta no son válidos."
        }
        let base = subtotal - descuento
        guard igv == ImporteVenta.redondear(base * 18 / 100), total == base + igv else {
            return "El descuento, el IGV y el total de la venta no coinciden."
        }
        return nil
    }

    func textoCompartido(anulada: Bool, motivo: String?) -> String {
        var texto = """
        VENTAS TECSUP
        BOLETA DE DEMOSTRACIÓN
        DOCUMENTO ACADÉMICO · SIN VALOR TRIBUTARIO

        Número: \(identificador)
        Estado: \(anulada ? "ANULADA" : "Vigente")
        Fecha de generación: \(fechaEmision.formatted(date: .numeric, time: .shortened))
        Fecha de venta: \(fechaVenta.formatted(date: .numeric, time: .shortened))
        Cliente: \(cliente)
        \(tipoDocumento.rawValue): \(documento)
        Vendedor: \(vendedor)

        Producto: \(producto)
        Cantidad: \(cantidad)
        Precio unitario: \(precioUnitario.soles)
        Subtotal: \(subtotal.soles)
        Descuento: \(descuento.soles)
        IGV (18 %): \(igv.soles)
        Total: \(total.soles)

        Validación local de demostración. Sin envío a SUNAT.
        """
        if anulada { texto += "\nMotivo de anulación: \(motivo ?? "Sin motivo registrado")" }
        return texto
    }
}

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

    var documentoNormalizado: String {
        components(separatedBy: .whitespacesAndNewlines).joined().uppercased()
    }

    var unidadesPositivas: Int? {
        let texto = recortado
        guard texto.range(of: #"^[0-9]+$"#, options: .regularExpression) != nil,
              let unidades = Int(texto), unidades > 0 else { return nil }
        return unidades
    }
}

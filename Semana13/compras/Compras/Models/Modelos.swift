import Foundation
import SwiftData

enum Rol: String, CaseIterable, Identifiable {
    case comprador = "Comprador"
    case supervisor = "Supervisor"

    var id: String { rawValue }
}

@Model
final class Usuario {
    var nombre: String
    @Attribute(.unique) var usuario: String
    var clave: String
    var rol: String
    @Relationship(deleteRule: .deny, inverse: \Compra.comprador) var compras: [Compra] = []

    var esSupervisor: Bool { rol == Rol.supervisor.rawValue }

    init(nombre: String, usuario: String, clave: String, rol: Rol) {
        self.nombre = nombre
        self.usuario = usuario
        self.clave = clave
        self.rol = rol.rawValue
    }
}

@Model
final class Proveedor {
    var nombre: String
    @Attribute(.unique) var ruc: String
    @Relationship(deleteRule: .deny, inverse: \Compra.proveedor) var compras: [Compra] = []

    var totalComprado: Decimal {
        compras.filter { $0.estado == EstadoCompra.aprobada.rawValue }
            .reduce(0) { $0 + Decimal($1.total) }
    }

    var tieneDeuda: Bool { compras.contains { $0.porPagar } }

    init(nombre: String, ruc: String) {
        self.nombre = nombre
        self.ruc = ruc
    }
}

@Model
final class Producto {
    var nombre: String
    var categoria: String
    var stock: Int
    var costoPromedio: Double
    @Relationship(deleteRule: .deny, inverse: \Compra.producto) var compras: [Compra] = []

    var valorInventario: Decimal { (Decimal(stock) * Decimal(costoPromedio)).redondeadoAMoneda }

    init(nombre: String, categoria: String, stock: Int, costoPromedio: Double) {
        self.nombre = nombre
        self.categoria = categoria
        self.stock = stock
        self.costoPromedio = costoPromedio
    }
}

@Model
final class Compra {
    var fecha: Date
    var cantidad: Int
    var costoUnitario: Double
    var igv: Double
    var total: Double
    var alCredito: Bool
    var vence: Date
    var estado: String
    var pagada: Bool
    var motivoRechazo: String?
    var comprador: Usuario?
    var proveedor: Proveedor?
    var producto: Producto?

    var porPagar: Bool { estado == EstadoCompra.aprobada.rawValue && alCredito && !pagada }
    var subtotal: Decimal { (Decimal(total) - Decimal(igv)).redondeadoAMoneda }

    var efectoEnInventario: EfectoInventario? {
        guard let producto else { return nil }
        return EfectoInventario(stockActual: producto.stock,
                                costoActual: Decimal(producto.costoPromedio).redondeadoAMoneda,
                                cantidad: cantidad, costoUnitario: Decimal(costoUnitario).redondeadoAMoneda)
    }

    init(comprador: Usuario, proveedor: Proveedor, producto: Producto,
         cantidad: Int, costoUnitario: Decimal, importe: ImporteCompra, alCredito: Bool, fecha: Date) {
        self.comprador = comprador
        self.proveedor = proveedor
        self.producto = producto
        self.fecha = fecha
        self.cantidad = cantidad
        self.costoUnitario = NSDecimalNumber(decimal: costoUnitario).doubleValue
        self.alCredito = alCredito
        igv = NSDecimalNumber(decimal: importe.igv).doubleValue
        total = NSDecimalNumber(decimal: importe.total).doubleValue
        estado = EstadoCompra.pendiente.rawValue
        pagada = false
        vence = alCredito ? (Calendar.current.date(byAdding: .day, value: 30, to: fecha) ?? fecha) : fecha
    }
}

enum ProblemaCompra: LocalizedError {
    case permiso, datos, inventario, estado, motivo

    var errorDescription: String? {
        switch self {
        case .permiso: "Tu rol no permite esta operación."
        case .datos: "Selecciona el proveedor y el producto e ingresa una cantidad y un costo válidos."
        case .inventario: "No se pudo calcular el nuevo inventario de este producto."
        case .estado: "La compra ya no se encuentra en el estado requerido."
        case .motivo: "Escribe el motivo del rechazo."
        }
    }
}

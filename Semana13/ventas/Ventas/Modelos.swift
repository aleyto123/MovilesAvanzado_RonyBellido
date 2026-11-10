import Foundation
import SwiftData

enum Rol: String, CaseIterable, Identifiable {
    case vendedor = "Vendedor"
    case supervisor = "Supervisor"

    var id: String { rawValue }
}

@Model
final class Usuario {
    var nombre: String
    @Attribute(.unique) var usuario: String
    var clave: String
    var rol: String
    @Relationship(deleteRule: .deny, inverse: \Venta.vendedor) var ventas: [Venta] = []

    var esSupervisor: Bool { rol == Rol.supervisor.rawValue }

    init(nombre: String, usuario: String, clave: String, rol: Rol) {
        self.nombre = nombre
        self.usuario = usuario
        self.clave = clave
        self.rol = rol.rawValue
    }
}

@Model
final class Producto {
    var nombre: String
    var categoria: String
    var precio: Double
    var stock: Int
    @Relationship(deleteRule: .deny, inverse: \Venta.producto) var ventas: [Venta] = []

    init(nombre: String, categoria: String, precio: Double, stock: Int) {
        self.nombre = nombre
        self.categoria = categoria
        self.precio = precio
        self.stock = stock
    }
}

@Model
final class Cliente {
    var nombre: String
    var documento: String
    @Relationship(deleteRule: .deny, inverse: \Venta.cliente) var ventas: [Venta] = []

    var totalComprado: Decimal {
        ImporteVenta.redondear(ventas.filter { !$0.anulada }.reduce(0) { $0 + Decimal($1.total) })
    }

    var categoria: CategoriaCliente { CategoriaCliente(total: totalComprado) }

    init(nombre: String, documento: String) {
        self.nombre = nombre
        self.documento = documento
    }
}

@Model
final class Venta {
    var fecha: Date
    var cantidad: Int
    var precioUnitario: Double
    var descuento: Double
    var igv: Double
    var total: Double
    var anulada = false
    var motivoAnulacion: String?
    var vendedor: Usuario
    var producto: Producto
    var cliente: Cliente

    init(vendedor: Usuario, producto: Producto, cliente: Cliente, cantidad: Int, importe: ImporteVenta) {
        fecha = .now
        self.vendedor = vendedor
        self.producto = producto
        self.cliente = cliente
        self.cantidad = cantidad
        precioUnitario = producto.precio
        descuento = NSDecimalNumber(decimal: importe.descuento).doubleValue
        igv = NSDecimalNumber(decimal: importe.igv).doubleValue
        total = NSDecimalNumber(decimal: importe.total).doubleValue
    }
}

extension ModelContext {
    func guardarCambios() throws {
        do {
            try save()
        } catch {
            rollback()
            throw error
        }
    }
}

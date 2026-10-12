import UIKit

// MARK: - Class Producto
class Producto {
    let nombre: String
    let precio: Double
    var stock: Int
    
    init(nombre: String, precio: Double, stock: Int) {
        self.nombre = nombre
        self.precio = precio
        self.stock = stock
    }
}

// MARK: - Class ItemCarrito
class ItemCarrito {
    let producto: Producto
    var cantidad: Int
    
    init(producto: Producto, cantidad: Int) {
        self.producto = producto
        self.cantidad = cantidad
    }
    
    func subtotal() -> Double {
        return producto.precio * Double(cantidad)
    }
}

// MARK: - Class CarritoModel
class CarritoModel {
    var items: [ItemCarrito] = []
    
    // TODO A1: Agregar producto validando stock
    func agregar(producto: Producto, cantidad: Int) -> Bool {
        let cantidadActual = items.first(where: { $0.producto.nombre == producto.nombre })?.cantidad ?? 0
        if (cantidadActual + cantidad) > producto.stock {
            return false
        }
        
        if let item = items.first(where: { $0.producto.nombre == producto.nombre }) {
            item.cantidad += cantidad
        } else {
            items.append(ItemCarrito(producto: producto, cantidad: cantidad))
        }
        return true
    }
    
    // TODO A2: Subtotal
    func subtotal() -> Double {
        return items.reduce(0.0) { $0 + $1.subtotal() }
    }
    
    // TODO A3: Porcentaje Descuento
    func porcentajeDescuento() -> Double {
        let sub = subtotal()
        if sub >= 5000 { return 0.15 }
        if sub >= 2000 { return 0.10 }
        if sub >= 500 { return 0.05 }
        return 0.0
    }
    
    func montoDescuento() -> Double {
        return subtotal() * porcentajeDescuento()
    }
    
    func montoBase() -> Double {
        return subtotal() - montoDescuento()
    }
    
    func igv() -> Double {
        return montoBase() * 0.18
    }
    
    func total() -> Double {
        return montoBase() + igv()
    }
    
    // Regla 7: Categoría del cliente
    func categoriaCliente() -> String {
        let sub = subtotal()
        switch sub {
        case ..<500: return "Regular"
        case 500..<2000: return "Frecuente"
        case 2000..<5000: return "VIP"
        default: return "Premium"
        }
    }
    
    // TODO A4: Cantidad Total
    func cantidadTotal() -> Int {
        return items.reduce(0) { $0 + $1.cantidad }
    }
    
    // TODO A5: Vaciar
    func vaciar() {
        items.removeAll()
    }
    
    // Regla 9: Bajar stock y vaciar al confirmar
    func confirmarCompra() {
        for item in items {
            item.producto.stock -= item.cantidad
        }
        vaciar()
    }
}

// MARK: - Class ClienteModel
class ClienteModel {
    var nombre: String
    var dni: String
    var categoria: String
    
    init(nombre: String, dni: String, categoria: String = "Regular") {
        self.nombre = nombre
        self.dni = dni
        self.categoria = categoria
    }
}
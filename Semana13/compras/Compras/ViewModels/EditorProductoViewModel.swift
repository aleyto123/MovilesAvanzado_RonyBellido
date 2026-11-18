import Foundation
import Observation

@Observable
final class EditorProductoViewModel {
    var nombre: String
    var categoria: String
    var stock: String
    var costo: String
    var mensaje = ""
    let producto: Producto?

    init(producto: Producto?) {
        self.producto = producto
        nombre = producto?.nombre ?? ""
        categoria = producto?.categoria ?? ""
        stock = String(producto?.stock ?? 0)
        let importe = Decimal(producto?.costoPromedio ?? 0).redondeadoAMoneda
        costo = NSDecimalNumber(decimal: importe).stringValue
    }

    func guardar(en store: ComprasStore) -> Bool {
        guard !nombre.recortado.isEmpty, !categoria.recortado.isEmpty,
              let stock = stock.unidades, let costo = costo.importeMonetario,
              costo >= 0, stock == 0 || costo > 0 else {
            mensaje = "Completa el nombre y la categoría. El stock debe ser entero y necesita un costo positivo si hay unidades."
            return false
        }
        let costoPromedio = NSDecimalNumber(decimal: costo).doubleValue
        do {
            if let producto {
                producto.nombre = nombre.recortado
                producto.categoria = categoria.recortado
                producto.stock = stock
                producto.costoPromedio = costoPromedio
                try store.guardarCambios()
            } else {
                try store.insertar(Producto(nombre: nombre.recortado, categoria: categoria.recortado,
                                            stock: stock, costoPromedio: costoPromedio))
            }
            return true
        } catch {
            mensaje = "No se pudo guardar el producto."
            return false
        }
    }
}

import Foundation
import Observation
import SwiftData

@Observable
final class NuevaCompraViewModel {
    var proveedorID: PersistentIdentifier?
    var productoID: PersistentIdentifier?
    var textoCantidad = "1"
    var textoCosto = ""
    var alCredito = false
    var mensaje = ""

    var importe: ImporteCompra? {
        guard let cantidad = textoCantidad.unidades, cantidad > 0,
              let costo = textoCosto.importeMonetario, costo > 0 else { return nil }
        return ImporteCompra(costo: costo, cantidad: cantidad)
    }

    func registrar(proveedor: Proveedor?, producto: Producto?, comprador: Usuario, en store: ComprasStore) {
        guard let proveedor, let producto, let cantidad = textoCantidad.unidades,
              let costo = textoCosto.importeMonetario else { return }
        do {
            let compra = try store.registrarCompra(comprador: comprador, proveedor: proveedor, producto: producto,
                                                      cantidad: cantidad, costo: costo, alCredito: alCredito)
            proveedorID = nil
            productoID = nil
            textoCantidad = "1"
            textoCosto = ""
            alCredito = false
            mensaje = compra.estado == EstadoCompra.pendiente.rawValue
                ? "Compra enviada a aprobación por \(compra.total.soles)."
                : "Compra registrada por \(compra.total.soles)."
        } catch let problema as ProblemaCompra {
            mensaje = problema.localizedDescription
        } catch {
            mensaje = "No se pudo guardar la compra."
        }
    }
}

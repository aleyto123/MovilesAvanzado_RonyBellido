import Foundation
import Observation

@Observable
final class CatalogoViewModel {
    var busqueda = ""
    var mensaje = ""

    func borrar(_ seleccion: [Producto], por usuario: Usuario, en store: ComprasStore) {
        guard usuario.esSupervisor else { return }
        guard seleccion.allSatisfy({ $0.compras.isEmpty }) else {
            mensaje = "No se puede borrar un producto con compras asociadas."
            return
        }
        do { try store.borrar(seleccion) }
        catch { mensaje = "No se pudo borrar el producto." }
    }

    func filtrar(_ productos: [Producto]) -> [Producto] {
        let texto = busqueda.recortado
        return productos.filter {
            texto.isEmpty || $0.nombre.localizedStandardContains(texto) || $0.categoria.localizedStandardContains(texto)
        }
    }

    func borrar(_ seleccion: [Proveedor], por usuario: Usuario, en store: ComprasStore) {
        guard usuario.esSupervisor else { return }
        guard seleccion.allSatisfy({ $0.compras.isEmpty }) else {
            mensaje = "No se puede borrar un proveedor con compras asociadas."
            return
        }
        do { try store.borrar(seleccion) }
        catch { mensaje = "No se pudo borrar el proveedor." }
    }

    func filtrar(_ proveedores: [Proveedor]) -> [Proveedor] {
        let texto = busqueda.recortado
        return proveedores.filter {
            texto.isEmpty || $0.nombre.localizedStandardContains(texto) || $0.ruc.contains(texto)
        }
    }
}

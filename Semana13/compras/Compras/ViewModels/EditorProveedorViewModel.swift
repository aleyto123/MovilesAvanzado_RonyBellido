import Foundation
import Observation

@Observable
final class EditorProveedorViewModel {
    var nombre: String
    var ruc: String
    var mensaje = ""
    let proveedor: Proveedor?

    init(proveedor: Proveedor?) {
        self.proveedor = proveedor
        nombre = proveedor?.nombre ?? ""
        ruc = proveedor?.ruc ?? ""
    }

    func guardar(en store: ComprasStore) -> Bool {
        let documento = ruc.recortado
        guard !nombre.recortado.isEmpty, documento.esRUC else {
            mensaje = "Completa la razón social e ingresa un RUC de 11 dígitos."
            return false
        }
        do {
            if documento != proveedor?.ruc {
                guard try !store.existeProveedor(ruc: documento) else {
                    mensaje = "Ese RUC ya está registrado."
                    return false
                }
            }
            if let proveedor {
                proveedor.nombre = nombre.recortado
                proveedor.ruc = documento
                try store.guardarCambios()
            } else {
                try store.insertar(Proveedor(nombre: nombre.recortado, ruc: documento))
            }
            return true
        } catch {
            mensaje = "No se pudo guardar el proveedor."
            return false
        }
    }
}

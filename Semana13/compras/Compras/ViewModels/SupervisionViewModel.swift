import Foundation
import Observation

@Observable
final class SupervisionViewModel {
    var mensaje = ""

    func aprobar(_ compra: Compra, por usuario: Usuario, en store: ComprasStore) {
        do {
            try store.aprobar(compra, por: usuario)
        } catch let problema as ProblemaCompra {
            mensaje = problema.localizedDescription
        } catch {
            mensaje = "No se pudo aprobar la compra."
        }
    }

    func rechazar(_ compra: Compra, por usuario: Usuario, motivo: String, en store: ComprasStore) -> Bool {
        do {
            try store.rechazar(compra, por: usuario, motivo: motivo)
            return true
        } catch let problema as ProblemaCompra {
            mensaje = problema.localizedDescription
            return false
        } catch {
            mensaje = "No se pudo rechazar la compra."
            return false
        }
    }

    func pagar(_ compra: Compra, por usuario: Usuario, en store: ComprasStore) {
        do {
            try store.pagar(compra, por: usuario)
        } catch let problema as ProblemaCompra {
            mensaje = problema.localizedDescription
        } catch {
            mensaje = "No se pudo marcar la compra como pagada."
        }
    }
}

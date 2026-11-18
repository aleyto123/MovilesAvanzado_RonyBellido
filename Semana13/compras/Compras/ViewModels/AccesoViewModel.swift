import Foundation
import Observation

@Observable
final class AccesoViewModel {
    var usuario = ""
    var clave = ""
    var error = ""

    func validar(en store: ComprasStore) -> Usuario? {
        let identificador = usuario.recortado.lowercased()
        if let cuenta = try? store.buscarUsuario(identificador), cuenta.clave == clave {
            return cuenta
        } else {
            error = "Usuario o clave incorrectos"
            return nil
        }
    }
}

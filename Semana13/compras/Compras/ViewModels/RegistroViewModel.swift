import Foundation
import Observation

@Observable
final class RegistroViewModel {
    var nombre = ""
    var usuario = ""
    var clave = ""
    var confirmacion = ""
    var rol = Rol.comprador
    var disponible: Bool?
    var error = ""

    func comprobarDisponibilidad(en store: ComprasStore) {
        let identificador = usuario.recortado.lowercased()
        disponible = nil
        guard !identificador.isEmpty else { return }
        do { disponible = try store.buscarUsuario(identificador) == nil }
        catch { disponible = nil }
    }

    func registrar(en store: ComprasStore) -> Usuario? {
        let identificador = usuario.recortado.lowercased()
        guard !nombre.recortado.isEmpty, !identificador.isEmpty else {
            error = "Completa tu nombre y usuario."
            return nil
        }
        guard clave.count >= 6, clave == confirmacion else {
            error = "La clave debe tener al menos seis caracteres y coincidir con su confirmación."
            return nil
        }
        do {
            guard try store.buscarUsuario(identificador) == nil else {
                error = "Ese usuario ya existe."
                return nil
            }
            let cuenta = Usuario(nombre: nombre.recortado, usuario: identificador, clave: clave, rol: rol)
            try store.insertar(cuenta)
            return cuenta
        } catch {
            self.error = "No se pudo crear la cuenta."
            return nil
        }
    }
}

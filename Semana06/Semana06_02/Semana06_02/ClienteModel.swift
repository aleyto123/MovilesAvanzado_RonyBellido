import Foundation

struct ClienteModel {
    let codigo: Int32
    let apellido: String
    let nombre: String
    let dni: String
    
    init(pCodigo: Int32, pApellido: String, pNombre: String, pDni: String) {
        codigo = pCodigo
        apellido = pApellido
        nombre = pNombre
        dni = pDni
    }
}

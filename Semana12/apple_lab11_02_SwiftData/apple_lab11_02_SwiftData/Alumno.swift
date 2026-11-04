import Foundation
import SwiftData

@Model
final class Alumno {
    var apellido: String
    var nombre: String
    var dni: String

    init(apellido: String, nombre: String, dni: String) {
        self.apellido = apellido
        self.nombre = nombre
        self.dni = dni
    }
}
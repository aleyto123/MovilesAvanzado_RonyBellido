import Foundation
import SwiftData

@Model
final class Grupo {
    var nombre: String
    
    // Relación 1 a Muchos con Nullify
    @Relationship(deleteRule: .nullify, inverse: \Contacto.grupo)
    var contactos: [Contacto]?

    init(nombre: String) {
        self.nombre = nombre
        self.contactos = []
    }
}

@Model
final class Contacto {
    var nombre: String
    var telefono: String
    var direccion: String
    
    // Relación Muchos a 1
    var grupo: Grupo?

    init(nombre: String, telefono: String, direccion: String, grupo: Grupo? = nil) {
        self.nombre = nombre
        self.telefono = telefono
        self.direccion = direccion
        self.grupo = grupo
    }
}
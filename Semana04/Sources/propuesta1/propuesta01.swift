import Foundation

// ===== ACTIVIDAD PROPUESTA 01 =====

// Representa un curso y la cantidad de veces que se compra.
struct Curso {
    let nombre: String
    let precio: Double
    let cantidad: Int
}

// Representa el alumno y sus cursos.
class Alumno {
    let nombre: String
    let dni: String
    let esAlumnoTecsup: Bool
    var cursos: [Curso]

    init(nombre: String, dni: String, esAlumnoTecsup: Bool) {
        self.nombre = nombre
        self.dni = dni
        self.esAlumnoTecsup = esAlumnoTecsup
        self.cursos = []
    }

    // Agrega un curso a la lista.
    func agregarCurso(curso: Curso) {
        cursos.append(curso)
    }
}
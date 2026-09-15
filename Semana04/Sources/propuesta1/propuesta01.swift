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

    // Calcula el subtotal de los cursos.
    func calcularSubtotal() -> Double {
        var subtotal = 0.0

        for curso in cursos {
            subtotal += curso.precio * Double(curso.cantidad)
        }

        return subtotal
    }

    // Calcula el IGV del 18%.
    func calcularIGV() -> Double {
        return calcularSubtotal() * 0.18
    }

    // Calcula el total incluyendo IGV.
    func calcularTotalConIGV() -> Double {
        return calcularSubtotal() + calcularIGV()
    }

    // Descuento del 10% si lleva 3 o más cursos.
    func calcularDescuento10() -> Double {
        if cursos.count >= 3 {
            return calcularTotalConIGV() * 0.10
        }

        return 0.0
    }

    // Descuento especial de S/ 400 para alumnos Tecsup
    // que llevan 3 o más cursos.
    func calcularDescuentoTecsup() -> Double {
        if esAlumnoTecsup && cursos.count >= 3 {
            return 400.0
        }

        return 0.0
    }

    // Calcula el total final.
    func calcularTotalFinal() -> Double {
        return calcularTotalConIGV()
            - calcularDescuento10()
            - calcularDescuentoTecsup()
    }
}
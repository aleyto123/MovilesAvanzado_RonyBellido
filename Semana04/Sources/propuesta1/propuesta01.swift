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

    func agregarCurso(curso: Curso) {
        cursos.append(curso)
    }

    func calcularSubtotal() -> Double {
        var subtotal = 0.0

        for curso in cursos {
            subtotal += curso.precio * Double(curso.cantidad)
        }

        return subtotal
    }

    func calcularIGV() -> Double {
        return calcularSubtotal() * 0.18
    }

    func calcularTotalConIGV() -> Double {
        return calcularSubtotal() + calcularIGV()
    }

    func calcularDescuento10() -> Double {
        if cursos.count >= 3 {
            return calcularTotalConIGV() * 0.10
        }

        return 0.0
    }

    func calcularDescuentoTecsup() -> Double {
        if esAlumnoTecsup && cursos.count >= 3 {
            return 400.0
        }

        return 0.0
    }

    func calcularTotalFinal() -> Double {
        return calcularTotalConIGV()
            - calcularDescuento10()
            - calcularDescuentoTecsup()
    }

    // Muestra la factura.
    func mostrarFactura() {

        print("🎓 FACTURA DE CURSOS")
        print("Estudiante: \(nombre)")
        print("DNI: \(dni)")

        if esAlumnoTecsup {
            print("Alumno de Tecsup: Sí ✅")
        } else {
            print("Alumno de Tecsup: No")
        }

        print("----------------------------")

        for curso in cursos {
            let totalCurso = curso.precio * Double(curso.cantidad)

            if curso.cantidad > 1 {
                print("\(curso.nombre) x\(curso.cantidad) - S/ \(String(format: "%.2f", totalCurso))")
            } else {
                print("\(curso.nombre) x1 - S/ \(String(format: "%.2f", totalCurso))")
            }
        }

        print("----------------------------")

        print("Subtotal: S/ \(String(format: "%.2f", calcularSubtotal()))")

        print("IGV (18%): S/ \(String(format: "%.2f", calcularIGV()))")

        print("Total con IGV: S/ \(String(format: "%.2f", calcularTotalConIGV()))")

        if calcularDescuento10() > 0 {
            print("Descuento 10% por cantidad: -S/ \(String(format: "%.2f", calcularDescuento10())) ✅")
        }

        if calcularDescuentoTecsup() > 0 {
            print("Descuento especial Tecsup: -S/ \(String(format: "%.2f", calcularDescuentoTecsup())) ✅")
        }

        print("----------------------------")

        print("💰 TOTAL FINAL A PAGAR: S/ \(String(format: "%.2f", calcularTotalFinal()))")
    }
}
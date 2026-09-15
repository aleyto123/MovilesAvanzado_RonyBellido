// ===== CASO 2 — PARTE A: BIBLIOTECA (SIN IA) =====
// Autor: Rony Bellido

// TODO: Definición del Enum EstadoLibro
enum EstadoLibro {
    case disponible
    case prestado
}

// TODO: Definición del Struct Libro
struct Libro {
    let titulo: String
    let autor: String
    var estado: EstadoLibro = .disponible
}

// TODO: Clase Biblioteca con referencia única del sistema
class Biblioteca {
    var libros: [Libro] = []
    
    // TODO: Método para agregar libros al arreglo
    func agregar(libro: Libro) {
        libros.append(libro)
    }
    // TODO: Método prestar
    // FIX Explicación: Dado que 'Libro' es un struct (tipo valor), se modifica directamente 'libros[i].estado' por índice en lugar de trabajar sobre una copia.
    func prestar(titulo: String) -> Bool {
        for i in 0..<libros.count {
            if libros[i].titulo == titulo {
                if libros[i].estado == .disponible {
                    libros[i].estado = .prestado
                    print("Préstamo aprobado: \(titulo)")
                    return true
                } else {
                    print("Error: \(titulo) ya está prestado")
                    return false
                }
            }
        }
        print("Error: no existe \(titulo)")
        return false
    }
// TODO: Método devolver (Lógica inversa de préstamo)
    func devolver(titulo: String) -> Bool {
        for i in 0..<libros.count {
            if libros[i].titulo == titulo {
                if libros[i].estado == .prestado {
                    libros[i].estado = .disponible
                    print("Devolución registrada: \(titulo)")
                    return true
                } else {
                    print("Error: \(titulo) no está prestado")
                    return false
                }
            }
        }
        print("Error: no existe \(titulo)")
        return false
    }
    // TODO: Método inventario con mapeo de estado usando switch
    func inventario() {
        print("===== INVENTARIO =====")
        for libro in libros {
            var estadoTexto = ""
            switch libro.estado {
            case .disponible:
                estadoTexto = "disponible"
            case .prestado:
                estadoTexto = "prestado"
            }
            print("\(libro.titulo) (\(libro.autor)) - \(estadoTexto)")
        }
    }
}
// --- TODO 19: SIMULACIÓN COMPLETA ---
// PREDICT Respuesta: Al ejecutar las operaciones en orden, 'La ciudad y los perros' pasa por disponible -> prestado -> disponible, mientras que 'El Quijote' queda prestado y 'El Principito' lanza error por no existir.
let biblioteca = Biblioteca()

let libro1 = Libro(titulo: "Cien años de soledad", autor: "Gabriel García Márquez")
let libro2 = Libro(titulo: "La ciudad y los perros", autor: "Mario Vargas Llosa")
let libro3 = Libro(titulo: "El Quijote", autor: "Miguel de Cervantes")

biblioteca.agregar(libro: libro1)
biblioteca.agregar(libro: libro2)
biblioteca.agregar(libro: libro3)

_ = biblioteca.prestar(titulo: "La ciudad y los perros")
_ = biblioteca.prestar(titulo: "La ciudad y los perros")
_ = biblioteca.devolver(titulo: "La ciudad y los perros")
_ = biblioteca.prestar(titulo: "El Quijote")
_ = biblioteca.prestar(titulo: "El Principito")

biblioteca.inventario()
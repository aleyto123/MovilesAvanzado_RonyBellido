// ===== CASO 2 — PARTE B: BIBLIOTECA (CON IA) =====
// Docente: Juan León

// Pide a la IA el mismo enunciado de la Parte A, con las mismas firmas.
// IMPORTANTE: Agrega un comentario en CADA línea explicando qué hace.
//
// Ejemplo de comentario BUENO:
// libros[i].estado = .prestado   // modifica el struct DENTRO del array (una copia no serviría)
//
// Ejemplo de comentario MALO:
// libros[i].estado = .prestado   // cambia el estado

// TODO 20: pega aquí el código generado por la IA, ya comentado línea por línea

enum EstadoLibro {
    case disponible
    case prestado
}

struct Libro {
    let titulo: String
    let autor: String
    var estado: EstadoLibro = .disponible
}

class Biblioteca {
    var libros: [Libro] = [] // inicializa la lista de libros vacía

    func agregar(libro: Libro) {
        libros.append(libro) // agrega el libro recibido al arreglo
    }

    func prestar(titulo: String) -> Bool {
        for i in 0..<libros.count { // recorre por índice para poder modificar la estructura interna
            if libros[i].titulo == titulo { // evalúa coincidencia de título
                if libros[i].estado == .disponible { // verifica si está disponible
                    libros[i].estado = .prestado // modifica el struct DENTRO del array (una copia no serviría)
                    print("Préstamo aprobado: \(titulo)") // imprime mensaje de éxito
                    return true // confirma préstamo exitoso
                } else {
                    print("Error: \(titulo) ya está prestado") // notifica que ya fue prestado
                    return false // cancela operación
                }
            }
        }
        print("Error: no existe \(titulo)") // notifica que el libro no existe
        return false // cancela operación
    }

    func devolver(titulo: String) -> Bool {
        for i in 0..<libros.count { // recorre por índice para modificar directamente el elemento
            if libros[i].titulo == titulo { // evalúa coincidencia de título
                if libros[i].estado == .prestado { // verifica si figura como prestado
                    libros[i].estado = .disponible // modifica el struct DENTRO del array (una copia no serviría)
                    print("Devolución registrada: \(titulo)") // imprime mensaje de éxito
                    return true // confirma devolución exitosa
                } else {
                    print("Error: \(titulo) no está prestado") // notifica que no estaba prestado
                    return false // cancela operación
                }
            }
        }
        print("Error: no existe \(titulo)") // notifica que el libro no existe
        return false // cancela operación
    }

    func inventario() {
        print("===== INVENTARIO =====") // imprime cabecera
        for libro in libros { // recorre cada libro en el arreglo
            var estadoTexto = "" // almacena texto del estado
            switch libro.estado { // evalúa enum
            case .disponible:
                estadoTexto = "disponible" // asigna texto disponible
            case .prestado:
                estadoTexto = "prestado" // asigna texto prestado
            }
            print("\(libro.titulo) (\(libro.autor)) - \(estadoTexto)") // imprime formato final
        }
    }
}

let biblioteca = Biblioteca() // crea la instancia de la biblioteca

let libro1 = Libro(titulo: "Cien años de soledad", autor: "Gabriel García Márquez") // instancia libro 1
let libro2 = Libro(titulo: "La ciudad y los perros", autor: "Mario Vargas Llosa") // instancia libro 2
let libro3 = Libro(titulo: "El Quijote", autor: "Miguel de Cervantes") // instancia libro 3

biblioteca.agregar(libro: libro1) // registra libro 1
biblioteca.agregar(libro: libro2) // registra libro 2
biblioteca.agregar(libro: libro3) // registra libro 3

_ = biblioteca.prestar(titulo: "La ciudad y los perros") // prueba préstamo exitoso
_ = biblioteca.prestar(titulo: "La ciudad y los perros") // prueba préstamo duplicado
_ = biblioteca.devolver(titulo: "La ciudad y los perros") // prueba devolución exitosa
_ = biblioteca.prestar(titulo: "El Quijote") // prueba préstamo exitoso
_ = biblioteca.prestar(titulo: "El Principito") // prueba préstamo inexistente

biblioteca.inventario() // imprime reporte final
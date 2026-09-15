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
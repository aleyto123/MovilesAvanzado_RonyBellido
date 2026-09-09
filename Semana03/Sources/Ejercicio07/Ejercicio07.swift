// Desarrollado por: Rony Bellido
import Foundation // Importa librería principal

var inventario: [String: (Double, Int)] = [:] // Diccionario con clave String y tupla (precio, stock)
print("¿Cuántos productos registrará?") // Pide cantidad inicial
let cant = Int(readLine() ?? "") ?? 0 // Convierte la cantidad a entero

if cant > 0 { // Verifica que haya productos
    for i in 1...cant { // Itera N veces
        print("Nombre del producto \(i):") // Pide nombre
        let nombre = readLine() ?? "" // Guarda nombre
        print("Precio:") // Pide precio
        let precio = Double(readLine() ?? "") ?? 0 // Guarda precio
        print("Stock:") // Pide stock
        let stock = Int(readLine() ?? "") ?? 0 // Guarda stock
        inventario[nombre] = (precio, stock) // Guarda la tupla en el diccionario
    } // Fin del registro inicial
} // Fin de condición

var salir = false // Variable bandera para el menú
while !salir { // Bucle infinito hasta que salir sea true
    print("\n--- MENÚ ---") // Cabecera de menú
    print("1) Ver inventario") // Opción 1
    print("2) Buscar") // Opción 2
    print("3) Stock bajo") // Opción 3
    print("4) Valor total") // Opción 4
    print("5) Salir") // Opción 5
    let opcion = readLine() ?? "" // Lee opción del usuario
    
    switch opcion { // Evalúa la opción elegida
    case "1": // Caso ver inventario
        for (nombre, datos) in inventario { // Recorre inventario
            print("\(nombre) - S/.\(datos.0) - Stock: \(datos.1)") // Imprime datos tupla
        } // Fin de recorrido
    case "2": // Caso buscar
        print("Nombre a buscar:") // Pide el término
        let busqueda = readLine() ?? "" // Lee término
        if let datos = inventario[busqueda] { // Busca clave de forma segura
            print("Encontrado: S/.\(datos.0) (Stock: \(datos.1))") // Imprime hallazgo
        } else { // Si no lo encuentra
            print("No existe.") // Muestra error
        } // Fin de búsqueda
    case "3": // Caso stock bajo
        for (nombre, datos) in inventario { // Recorre inventario
            if datos.1 < 5 { // Evalúa stock menor a 5
                print("Stock bajo: \(nombre) (\(datos.1) unid.)") // Imprime advertencia
            } // Fin del if
        } // Fin del for
    case "4": // Caso valor total
        var total = 0.0 // Inicializa acumulador
        for (_, datos) in inventario { // Recorre ignorando claves
            total += (datos.0 * Double(datos.1)) // Suma precio por stock
        } // Fin del for
        print("Valor total: S/.\(total)") // Imprime patrimonio total
    case "5": // Caso salir
        salir = true // Cambia bandera para salir
    default: // Ingresos inválidos
        print("Inválido.") // Muestra error
    } // Fin del switch
} // Fin del while
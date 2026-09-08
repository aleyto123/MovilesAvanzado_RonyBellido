// Desarrollado por: Rony Bellido
import Foundation

// TODO 4: Catálogo de productos
var productos: [String: Double] = [:]
for i in 1...4 {
    print("Producto \(i) Nombre:")
    let nombre = readLine() ?? ""
    print("Precio:")
    let precio = Double(readLine() ?? "") ?? 0
    productos[nombre] = precio
}

// TODO 5: Mostrar catalogo
print("\n--- CATALOGO ---")
for (nombre, precio) in productos {
    print("\(nombre): S/. \(precio)")
}

// TODO 6: Valor total
var valorTotal = 0.0
for (_, precio) in productos {
    valorTotal += precio
}
print("Valor total: S/. \(valorTotal)")

// TODO 7: Buscar producto
print("Buscar producto:")
let buscarProd = readLine() ?? ""
if let precioEncontrado = productos[buscarProd] {
    print("\(buscarProd) cuesta S/. \(precioEncontrado)")
} else {
    print("Producto no encontrado")
}

// ANALYZE
var edades: [String: Int] = ["Ana": 20, "Luis": 22, "Maria": 19]
var mayores: [String] = []
for (nombre, edad) in edades {
    if edad > 21 {
        mayores.append(nombre)
    }
}
print("Mayores de 21: \(mayores)")
// ANALYZE 1: Filtra el diccionario iterando claves y valores. Si la edad es mayor a 21, guarda el nombre en el arreglo 'mayores'. Imprime: ["Luis"].
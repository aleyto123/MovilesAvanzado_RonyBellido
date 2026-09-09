// Desarrollado por: Rony Bellido
import Foundation

// TODO 10: Inventario de productos
var preciosInventario: [String: Double] = [:]
var stocks: [String: Int] = [:]

print("¿Cuántos productos?")
let n = Int(readLine() ?? "") ?? 0

for i in 1...n {
    print("Producto \(i) Nombre:")
    let nombre = readLine() ?? ""
    print("Precio:")
    let precio = Double(readLine() ?? "") ?? 0
    print("Stock:")
    let stock = Int(readLine() ?? "") ?? 0
    
    preciosInventario[nombre] = precio
    stocks[nombre] = stock
}

// Calcular valor total e identificar stock bajo
var valorTotalInventario = 0.0
print("\n--- PRODUCTOS CON STOCK BAJO (<= 5) ---")
for (producto, stock) in stocks {
    if let precio = preciosInventario[producto] {
        valorTotalInventario += (precio * Double(stock))
    }
    if stock <= 5 {
        print("\(producto) tiene un stock crítico de \(stock)")
    }
}
print("\nValor total del inventario: S/. \(valorTotalInventario)")
import Foundation

// --- PASO 1: LECTURA DE DATOS ---
print("nombre del producto:")
let producto = readLine() ?? ""

print("precio unit:")
let precioUnit = Double(readLine() ?? "0") ?? 0.0

print("cantidad:")
let cantidad = Int(readLine() ?? "0") ?? 0

// Cálculo del monto total inicial
let montoTotalCompra = precioUnit * Double(cantidad)

print("\nMONTO TOTAL DE LA COMPRA: S/ \(montoTotalCompra)")

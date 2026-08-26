import Foundation

// 1. Porcentaje fijo
let igvPorcentaje = 0.18

func calcularDescuento(cantidad: Int, subtotal: Double) -> Double {
    if cantidad > 10 {
        return subtotal * 0.15
    } else if cantidad > 5 {
        return subtotal * 0.10
    } else {
        return 0.0
    }
}

print("ingrese el nombre del producto: ")
let producto = readLine() ?? ""

print("ingrese el precio del producto: ")
let precio = Double(readLine() ?? "0") ?? 0.0

print("ingrese la cantidad del producto: ")
let cantidad = Int(readLine() ?? "0") ?? 0

// 2. Cálculos corregidos
let subtotal = precio * Double(cantidad)
let descuento = calcularDescuento(cantidad: cantidad, subtotal: subtotal)

// Hallar el monto base: subtotal - descuento
let montoBase = subtotal - descuento

// Hallar el igv = montoBase * igvPorcentaje
let igv = montoBase * igvPorcentaje

// Total = montoBase + igv
let total = montoBase + igv

print("\n--- RESUMEN DE COMPRA ---")
print("Producto: \(producto)")
print("Subtotal: S/ \(subtotal)")
print("Descuento: S/ \(descuento)")
print("Monto Base: S/ \(montoBase)")
print("IGV (18%): S/ \(igv)")
print("Total a pagar: S/ \(total)")

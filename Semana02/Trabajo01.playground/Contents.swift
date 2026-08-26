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

// --- PASO 2: PLAN DE PAGO ---
print("elige el plan de pago (6,12,24):")
let planCuotas = Int(readLine() ?? "0") ?? 6

var porcentajeInteres: Double = 0.0

switch planCuotas {
case 6:
    porcentajeInteres = 0.20
case 12:
    porcentajeInteres = 0.40
case 24:
    porcentajeInteres = 0.60
default:
    porcentajeInteres = 0.0
}

let interesMonto = montoTotalCompra * porcentajeInteres
let montoFinal = montoTotalCompra + interesMonto
let montoCuota = montoFinal / Double(planCuotas)



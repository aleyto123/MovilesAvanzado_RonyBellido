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

// --- PASO 3: RESUMEN DEL PLAN DE PAGO ---
print("\nPLAN DE PAGO")
print("producto : \(producto)    interes: S/ \(interesMonto)    cuota: \(planCuotas) meses")
print("monto cuota: S/ \(montoCuota)    monto final: S/ \(montoFinal)\n")

// --- PASO 4: TABLA DE CRONOGRAMA DE PAGOS ---
print("Mes\tmonto inicial\tcuota mensual\tresta x pago")

var saldoPendiente = montoFinal

for mes in 1...planCuotas {
    let montoInicialMes = saldoPendiente
    saldoPendiente -= montoCuota
    
    // Evitar decimales negativos en el último mes por redondeo
    if saldoPendiente < 0 { saldoPendiente = 0.0 }
    
    print("\(mes)\t\(String(format: "%.2f", montoInicialMes))\t\t\(String(format: "%.2f", montoCuota))\t\t\(String(format: "%.2f", saldoPendiente))")
}

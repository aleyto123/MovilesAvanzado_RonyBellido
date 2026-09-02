import Foundation

struct DatosCompra {
    let nombre: String
    let precio: Double
    let cantidad: Int
    let montoTotal: Double
    let planPago: Int
    let mesAdelantado: Int
    let montoAdicional: Double
}

func capturarDatos() -> DatosCompra {
    print("Nombre producto: ", terminator: "")
    let nombre = readLine() ?? ""

    print("precio unitario: ", terminator: "")
    let precio = Double(readLine() ?? "") ?? 0.0

    print("cantidad: ", terminator: "")
    let cantidad = Int(readLine() ?? "") ?? 0

    let montoTotal = precio * Double(cantidad)
    print(String(format: "monto total compra : %.2f", montoTotal))

    var plan = 0
    while ![6, 12, 24].contains(plan) {
        print("Plan de pago(6,12,24) haya que validar: ", terminator: "")
        plan = Int(readLine() ?? "") ?? 0
    }

    print("¿en que mes hara un pago adelantado? (0 = ninguno): ", terminator: "")
    let mesAdelantado = Int(readLine() ?? "") ?? 0

    var montoAdicional = 0.0
    if mesAdelantado > 0 {
        print("monto adicional a pagar ese mes (s/.): ", terminator: "")
        montoAdicional = Double(readLine() ?? "") ?? 0.0
    }

    return DatosCompra(
        nombre: nombre,
        precio: precio,
        cantidad: cantidad,
        montoTotal: montoTotal,
        planPago: plan,
        mesAdelantado: mesAdelantado,
        montoAdicional: montoAdicional
    )
}
func generarFechas(cantidadCuotas: Int, fechaInicio: Date = Date()) -> [String] {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    
    var fechas: [String] = []
    let calendar = Calendar.current
    
    for i in 0..<cantidadCuotas {
        if let fechaFutura = calendar.date(byAdding: .month, value: i, to: fechaInicio) {
            fechas.append(formatter.string(from: fechaFutura))
        }
    }
    return fechas
}
struct RegistroAmortizacion {
    let mes: Int
    let fecha: String
    let montoInicial: Double
    let pago: Double
    let restaPorPagar: Double
}

func calcularTablaAmortizacion(datos: DatosCompra, fechas: [String]) -> [RegistroAmortizacion] {
    let cuotaBase = datos.montoTotal / Double(datos.planPago)
    var montoInicial = datos.montoTotal
    var registros: [RegistroAmortizacion] = []

    for i in 0..<datos.planPago {
        let mesActual = i + 1
        var pagoMes = cuotaBase

        if mesActual == datos.mesAdelantado {
            pagoMes += datos.montoAdicional
        }

        var resta = montoInicial - pagoMes
        if resta < 0 {
            resta = 0.0
        }

        let registro = RegistroAmortizacion(
            mes: mesActual,
            fecha: fechas[i],
            montoInicial: montoInicial,
            pago: pagoMes,
            restaPorPagar: resta
        )
        registros.append(registro)

        montoInicial = resta
        if resta == 0 {
            break
        }
    }
    return registros
}
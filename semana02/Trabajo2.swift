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

        // CORRECCIÓN MATEMÁTICA: Evitar cobrar de más si la deuda restante es menor a la cuota
        if pagoMes > montoInicial {
            pagoMes = montoInicial
        }

        let resta = montoInicial - pagoMes

        let registro = RegistroAmortizacion(
            mes: mesActual,
            fecha: fechas[i],
            montoInicial: montoInicial,
            pago: pagoMes,
            restaPorPagar: resta
        )
        registros.append(registro)

        montoInicial = resta
        
        // Si ya no hay deuda, terminamos de generar la tabla
        if resta <= 0 {
            break
        }
    }
    return registros
}

func imprimirReporte(registros: [RegistroAmortizacion], planTotal: Int) {
    print("\n----------------- PLAN DE PAGO -----------------")
    print(String(format: "%-5s %-12s %-15s %-10s %-15s", "MES", "FECHA", "MONTO INICIAL", "PAGO", "RESTA POR PAGAR"))

    for r in registros {
        print(String(format: "%-5d %-12s %-15.2f %-10.2f %-15.2f", r.mes, r.fecha, r.montoInicial, r.pago, r.restaPorPagar))
    }

    print(String(format: "\nLEYENDA DE MESES PAGADOS %d DE %d", registros.count, planTotal))
}

// CORRECCIÓN ESTRUCTURAL PARA SWIFT 6
@main
struct App {
    static func main() {
        let datos = capturarDatos()
        let fechas = generarFechas(cantidadCuotas: datos.planPago)
        let cronograma = calcularTablaAmortizacion(datos: datos, fechas: fechas)
        imprimirReporte(registros: cronograma, planTotal: datos.planPago)
    }
}
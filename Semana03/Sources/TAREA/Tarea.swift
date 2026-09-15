// ============================================================================
// DESARROLLADO POR: Rony Bellido
// DOCENTE: Juan Leon - Tecsup
// CURSO: Programación Móvil Avanzada
// PROYECTO: Sistema de Red Metropolitana, Tarifario y Tarjeta de Transporte
// ============================================================================

import Foundation

// 1. ESTADO DE OPERATIVIDAD
enum EstadoServicio {
    case operativo
    case fueraDeServicio
    
    var indicador: String {
        switch self {
        case .operativo: return "(F)"
        case .fueraDeServicio: return "(NF)"
        }
    }
    
    var descripcion: String {
        switch self {
        case .operativo: return "En Funcionamiento"
        case .fueraDeServicio: return "En Proyecto / Obras"
        }
    }
}

// 2. MODELO DE ESTACIÓN
struct EstacionRed {
    let identificador: String
    let nombre: String
    let lineaPertenencia: String
    let posicion: Int
    let estado: EstadoServicio
    let accesoDiscapacidad: Bool
    let cruceAvenidas: String
    let puntosInteres: [String]
    let frecuenciaMinutos: Int
    
    func obtenerFichaDetallada(tarifa: Double) -> String {
        let cod = identificador.isEmpty ? "" : "[\(identificador)] "
        return """
        --------------------------------------------------
        📍 ESTACIÓN: \(cod)\(nombre.uppercased()) \(estado.indicador)
        --------------------------------------------------
        • Red/Línea       : \(lineaPertenencia) (Posición \(posicion))
        • Tarifa General  : S/ \(String(format: "%.2f", tarifa))
        • Estado Actual   : \(estado.descripcion)
        • Cruce Vial      : \(cruceAvenidas)
        • Accesibilidad   : \(accesoDiscapacidad ? "♿ Accesible (Ascensores / Rampas)" : "🚫 Sin elevador confirmado")
        • Frecuencia Tren : Cada \(frecuenciaMinutos) minutos aprox.
        • Puntos Cercanos : \(puntosInteres.joined(separator: ", "))
        --------------------------------------------------
        """
    }
}

// 3. MODELO DE LÍNEA CON TARIFAS
struct LineaTransporte {
    let denominacion: String
    let colorIdentificador: String
    let tarifaAdulto: Double
    let tarifaMedio: Double
    var paraderos: [EstacionRed] = []
    
    func imprimirCatalogo() {
        print("\n==========================================")
        print("RED: \(denominacion.uppercased()) (Color: \(colorIdentificador))")
        print("💵 Tarifa General: S/ \(String(format: "%.2f", tarifaAdulto)) | Medio Pasaje: S/ \(String(format: "%.2f", tarifaMedio))")
        print("==========================================")
        for p in paraderos {
            print("  \(p.posicion). \(p.nombre) \(p.estado.indicador) — Ubicación: \(p.cruceAvenidas)")
        }
        print("Total de estaciones registradas: \(paraderos.count)")
    }
}

// 4. MODELO DE TRANSBORDO
struct TransbordoRed {
    let origenLinea: String
    let origenEstacion: String
    let destinoLinea: String
    let destinoEstacion: String
    let modalidad: String
    let referenciaUbicacion: String
    let tiempoEstimadoMin: Int
}

// 5. GESTOR CENTRAL DE LA RED Y PLANIFICADOR DE COSTOS
class GestorRedTransporte {
    var lineasRed: [LineaTransporte] = []
    var listaTransbordos: [TransbordoRed] = []
    
    func registrarLinea(_ linea: LineaTransporte) { lineasRed.append(linea) }
    func registrarTransbordo(_ transbordo: TransbordoRed) { listaTransbordos.append(transbordo) }
    
    var todasLasEstaciones: [EstacionRed] {
        return lineasRed.flatMap { $0.paraderos }
    }
    
    func consultarParadero(_ patron: String) -> [(estacion: EstacionRed, tarifa: Double)] {
        var lista: [(estacion: EstacionRed, tarifa: Double)] = []
        let eEncontradas = todasLasEstaciones.filter { $0.nombre.lowercased().contains(patron.lowercased()) }
        
        for e in eEncontradas {
            let tarifa = lineasRed.first(where: { $0.denominacion == e.lineaPertenencia })?.tarifaAdulto ?? 0.0
            lista.append((e, tarifa))
        }
        return lista
    }
    
    func planificarRutaADestino(_ destinoBuscado: String) -> [(estacion: EstacionRed, hitoEncontrado: String, tarifaAdulto: Double, tarifaMedio: Double)] {
        var coincidencias: [(estacion: EstacionRed, hitoEncontrado: String, tarifaAdulto: Double, tarifaMedio: Double)] = []
        let termino = destinoBuscado.lowercased()
        
        for estacion in todasLasEstaciones {
            let linea = lineasRed.first(where: { $0.denominacion == estacion.lineaPertenencia })
            let tAdulto = linea?.tarifaAdulto ?? 0.0
            let tMedio = linea?.tarifaMedio ?? 0.0
            
            if estacion.nombre.lowercased().contains(termino) {
                coincidencias.append((estacion, "Coincidencia directa de estación", tAdulto, tMedio))
            } else {
                for hito in estacion.puntosInteres {
                    if hito.lowercased().contains(termino) {
                        coincidencias.append((estacion, hito, tAdulto, tMedio))
                    }
                }
            }
        }
        return coincidencias
    }
    
    func obtenerPorEstado(_ estadoBuscado: EstadoServicio) -> [EstacionRed] {
        return todasLasEstaciones.filter { $0.estado == estadoBuscado }
    }
    
    func obtenerConAccesoElevador() -> [EstacionRed] {
        return todasLasEstaciones.filter { $0.accesoDiscapacidad }
    }
    
    func desplegarTransbordos() {
        print("\n==========================================")
        print("🔗 PUNTOS DE TRANSBORDO E INTERCAMBIO")
        print("==========================================")
        for t in listaTransbordos {
            print("• \(t.origenLinea) (\(t.origenEstacion)) ⇄ \(t.destinoLinea) (\(t.destinoEstacion))")
            print("  - Modalidad  : \(t.modalidad)")
            print("  - Ubicación  : \(t.referenciaUbicacion)")
            print("  - Caminata   : ~\(t.tiempoEstimadoMin) minutos aproximadamente\n")
        }
    }
}

func imprimirLeyendaSistema() {
    print("\n==========================================")
    print("📖 LEYENDA TÉCNICA Y SIMBOLOGÍA DEL SISTEMA")
    print("==========================================")
    print(" (F)   : Estación Operativa (En servicio activo)")
    print(" (NF)  : Estación No Operativa (En proyecto o infraestructura en obras)")
    print(" [E-XX]: Código oficial de infraestructura asignado")
    print(" 💳    : Saldo en tarjeta de transporte disponible / requerido")
    print(" ♿     : Estación adaptada para personas con movilidad reducida")
    print(" 🔗     : Nodo de transferencia entre líneas")
    print("==========================================\n")
}

// ============================================================================
// CONFIGURACIÓN DE LA BASE DE DATOS Y TARIFARIO (Rony Bellido)
// ============================================================================
let redCentral = GestorRedTransporte()

// LÍNEA 1 (Tarifa: Adulto S/ 1.50, Universitario/Escolar S/ 0.75)
var l1 = LineaTransporte(denominacion: "Linea 1", colorIdentificador: "Verde", tarifaAdulto: 1.50, tarifaMedio: 0.75)
let datosL1: [(nom: String, cruce: String, hitos: [String], acc: Bool)] = [
    ("Villa El Salvador", "Av. Separadora Industrial con Av. Velasco", ["Parque Industrial", "Muni Villa El Salvador"], true),
    ("Parque Industrial", "Av. Separadora Industrial con Av. El Sol", ["Zona Industrial Villa El Salvador"], true),
    ("Pumacahua", "Av. Unión con Av. Pumacahua", ["Hospital de la Solidaridad VMT"], false),
    ("Villa Maria", "Av. Pachacútec con Av. San Aconcagua", ["Plaza de Armas VMT"], false),
    ("Maria Auxiliadora", "Av. Pachacútec con Av. Miguel Iglesias", ["Hospital María Auxiliadora"], false),
    ("San Juan", "Av. Los Héroes con Av. San Juan", ["C.C. Open Plaza Atocongo"], true),
    ("Atocongo", "Av. Los Héroes con Av. Circunvalación", ["Mall del Sur", "Puente Atocongo"], true),
    ("Jorge Chavez", "Av. Tomás Marsano con Av. Jorge Chávez", ["Plaza Vea Higuereta"], true),
    ("Ayacucho", "Av. Tomás Marsano con Av. Ayacucho", ["Plaza de Surco", "Parque Amistad"], true),
    ("Cabitos", "Av. Aviación con Av. Benavides", ["Óvalo Higuereta", "Polvos Higuereta"], true),
    ("Angamos", "Av. Aviación con Av. Angamos Este", ["Open Plaza Angamos", "INEN Instituto Neoplásicas"], true),
    ("San Borja Sur", "Av. Aviación con Av. San Borja Sur", ["Parque de la Felicidad", "Pentagonito"], false),
    ("La Cultura", "Av. Javier Prado con Av. Aviación", ["Teatro Nacional", "Museo de la Nación", "Biblioteca Nacional"], true),
    ("Arriola", "Av. Aviación con Av. Pablo Cánepa", ["Mercado de Frutas", "La Victoria"], true),
    ("Gamarra", "Av. Aviación con Jr. Hipólito Unanue", ["Emporio Comercial Gamarra", "Parque Cánepa"], true),
    ("Miguel Grau", "Av. Miguel Grau con Av. Aviación", ["Hospital Almenara", "Parque Universitario"], true),
    ("El Angel", "Av. Locumba con Jr. Ancash", ["Cementerio El Ángel"], true),
    ("Presbitero Maestro", "Av. Locumba con Av. Cementerio", ["Museo Cementerio Presbítero Maestro"], true),
    ("Caja de Agua", "Av. Próceres de la Independencia con Jr. Lima", ["Entrada SJL"], true),
    ("Piramide del Sol", "Av. Próceres con Av. Pirámide del Sol", ["Zona Comercial Zárate"], true),
    ("Los Jardines", "Av. Próceres N° 1600", ["Plaza Vea Zárate", "Metro de Hacienda"], true),
    ("Los Postes", "Av. Próceres N° 2100", ["Parque Zonal Huiracocha"], true),
    ("San Carlos", "Av. Próceres con Av. El Sol", ["Universidad CTP", "UTP SJL"], true),
    ("San Martin", "Av. Fernando Wiesse con Av. San Martín", ["Mercado San Martín"], true),
    ("Santa Rosa", "Av. Fernando Wiesse con Av. Santa Rosa", ["Comisaría Santa Rosa"], true),
    ("Bayovar", "Av. Fernando Wiesse con Av. Bayóvar", ["Plaza Vea Bayóvar", "Universidad UMA"], true)
]

for (idx, d) in datosL1.enumerated() {
    l1.paraderos.append(EstacionRed(identificador: "", nombre: d.nom, lineaPertenencia: "Linea 1", posicion: idx + 1, estado: .operativo, accesoDiscapacidad: d.acc, cruceAvenidas: d.cruce, puntosInteres: d.hitos, frecuenciaMinutos: 4))
}
redCentral.registrarLinea(l1)

// LÍNEA 2 (Tarifa: Adulto S/ 1.40, Universitario/Escolar S/ 0.70)
var l2 = LineaTransporte(denominacion: "Linea 2", colorIdentificador: "Amarillo", tarifaAdulto: 1.40, tarifaMedio: 0.70)
let datosL2: [(nom: String, cruce: String, hitos: [String])] = [
    ("Puerto del Callao", "Av. Guardia Chalaca con Av. Buenos Aires", ["Puerto del Callao", "Fortaleza Real Felipe"]),
    ("Buenos Aires", "Av. Oscar R. Benavides con Av. Buenos Aires", ["Mercado Central del Callao"]),
    ("Juan Pablo II", "Av. Oscar R. Benavides con Av. Juan Pablo II", ["Minka", "Universidad del Callao"]),
    ("Insurgentes", "Av. Oscar R. Benavides con Av. Insurgentes", ["Bellavista Callao"]),
    ("Carmen de la Legua", "Av. Faucett con Av. Oscar R. Benavides", ["Hospital San José"]),
    ("Oscar R. Benavides", "Av. Oscar R. Benavides con Av. Colonial", ["Mallplaza Bellavista"]),
    ("San Marcos", "Av. Venezuela con Av. Universitario", ["UNMSM Universidad San Marcos"]),
    ("Elio", "Av. Venezuela con Av. Germán Amezaga", ["Unidad Vecinal Muelle"]),
    ("La Alborada", "Av. Venezuela con Av. Alejandro Bertello", ["Pueblo Libre Norte"]),
    ("Tingo Maria", "Av. Venezuela con Av. Tingo María", ["Universidad Simón Bolívar"]),
    ("Parque Murillo", "Av. Arica con Av. Aguarico", ["Plaza Bolognesi", "Breña"]),
    ("Plaza Bolognesi", "Av. Arica con Guzmán Blanco", ["Plaza Bolognesi", "Paseo Colón"]),
    ("Estacion Central", "Paseo Colón con Paseo de la República", ["Centro Cívico", "Estadio Nacional", "Plaza San Martín"]),
    ("Manco Capac", "Av. 28 de Julio con Av. Manco Cápac", ["Plaza Manco Cápac"]),
    ("Cangallo", "Av. 28 de Julio con Jr. Cangallo", ["Hospital Nacional Dos de Mayo"]),
    ("28 de Julio", "Av. 28 de Julio con Av. Aviación", ["Emporio Gamarra Norte"]),
    ("Nicolas Ayllon", "Av. Nicolás Ayllón con Av. México", ["Plaza Vitarte"]),
    ("Circunvalacion", "Av. Nicolás Ayllón con Av. Circunvalación", ["El Agustino"]),
    ("San Juan de Dios", "Av. Nicolás Ayllón con Av. San Juan", ["Clínica San Juan de Dios"]),
    ("Evitamiento", "Carretera Central con Vía Evitamiento", ["Mall Aventura Santa Anita"]),
    ("Ovalo Santa Anita", "Carretera Central con Av. Los Ruiseñores", ["Óvalo Santa Anita"]),
    ("Colectora Industrial", "Carretera Central con Av. Colectora", ["Zona Industrial Ate"]),
    ("Hermilio Valdizan", "Carretera Central con Av. Valdizán", ["Hospital Hermilio Valdizán"]),
    ("Mercado Santa Anita", "Carretera Central con Av. Metropolitano", ["Mercado Mayorista de Santa Anita"]),
    ("Vista Alegre", "Carretera Central con Av. Vista Alegre", ["Ceres Medio"]),
    ("Prolongacion Javier Prado", "Carretera Central con Prolongación Javier Prado", ["Estadio Monumental U"]),
    ("Municipalidad de Ate", "Carretera Central con Av. Nicolás de Piérola", ["Municipalidad de Ate"])
]

for (idx, d) in datosL2.enumerated() {
    let num = idx + 1
    let cod = String(format: "E-%02d", num)
    let enServicio = (num >= 20 && num <= 24)
    l2.paraderos.append(EstacionRed(identificador: cod, nombre: d.nom, lineaPertenencia: "Linea 2", posicion: num, estado: enServicio ? .operativo : .fueraDeServicio, accesoDiscapacidad: enServicio, cruceAvenidas: d.cruce, puntosInteres: d.hitos, frecuenciaMinutos: 6))
}
redCentral.registrarLinea(l2)

// REGISTRO DE TRANSBORDOS
redCentral.registrarTransbordo(TransbordoRed(origenLinea: "Linea 1", origenEstacion: "Gamarra", destinoLinea: "Linea 2", destinoEstacion: "28 de Julio", modalidad: "Conexión peatonal asistida", referenciaUbicacion: "Av. Aviación esquina con Av. 28 de Julio", tiempoEstimadoMin: 6))
redCentral.registrarTransbordo(TransbordoRed(origenLinea: "Linea 2", origenEstacion: "Estacion Central", destinoLinea: "Metropolitano", destinoEstacion: "Estación Central", modalidad: "Hub Intermodal Subterráneo", referenciaUbicacion: "Paseo de la República / Centro Cívico", tiempoEstimadoMin: 2))

// ============================================================================
// INTERFAZ Y MENÚ INTERACTIVO CON VERIFICACIÓN DE SALDO
// ============================================================================
var sistemaActivo = true

while sistemaActivo {
    print("\n--------------------------------------------------")
    print("      SISTEMA METROPOLITANO Y CALCULADORA DE PASAJE")
    print("             Desarrollado por: Rony Bellido")
    print("--------------------------------------------------")
    print("1. Consultar estaciones y tarifas por línea")
    print("2. Buscar ficha técnica y costo de estación")
    print("3. Planificar ruta, costo y consultar si alcanza el saldo")
    print("4. Ver puntos de transbordo e intercambios")
    print("5. Filtrar catálogo (Estado / Accesibilidad)")
    print("6. Ver Leyenda de Simbología")
    print("7. Salir")
    print("Seleccione una opción:")
    
    let entrada = readLine() ?? ""
    
    switch entrada {
    case "1":
        print("\nIngrese el número de línea a consultar (1 - 2):")
        if let num = Int(readLine() ?? ""), num >= 1 && num <= redCentral.lineasRed.count {
            redCentral.lineasRed[num - 1].imprimirCatalogo()
        } else {
            print("❌ Selección fuera de rango.")
        }
        
    case "2":
        print("\nIngrese el nombre de la estación:")
        let termino = readLine() ?? ""
        let resultados = redCentral.consultarParadero(termino)
        
        if resultados.isEmpty {
            print("❌ No se registraron estaciones con ese nombre.")
        } else {
            for res in resultados {
                print(res.estacion.obtenerFichaDetallada(tarifa: res.tarifa))
            }
        }
        
    case "3":
        print("\n¿A qué lugar o punto de interés deseas ir?")
        print("Ejemplos: Gamarra, Estadio Nacional, Minka, Teatro Nacional, Mall del Sur")
        let destino = readLine() ?? ""
        let rutas = redCentral.planificarRutaADestino(destino)
        
        if rutas.isEmpty {
            print("❌ No se hallaron estaciones con cercanía a '\(destino)'.")
        } else {
            print("\n==================================================")
            print("🗺️ RUTAS Y COSTOS SUGERIDOS PARA LLEGAR A: '\(destino.uppercased())'")
            print("==================================================")
            
            for (idx, r) in rutas.enumerated() {
                print("Opción \(idx + 1): Bajar en estación \(r.estacion.nombre.uppercased()) \(r.estacion.estado.indicador)")
                print("  • Red/Línea       : \(r.estacion.lineaPertenencia)")
                print("  • Ubicación       : \(r.estacion.cruceAvenidas)")
                print("  • Referencia      : \(r.hitoEncontrado)")
                print("  • Pasaje Adulto   : S/ \(String(format: "%.2f", r.tarifaAdulto))")
                print("  • Pasaje Medio    : S/ \(String(format: "%.2f", r.tarifaMedio))\n")
            }
            
            let costoRequerido = rutas[0].tarifaAdulto
            
            print("--------------------------------------------------")
            print("💳 VERIFICACIÓN DE PRESUPUESTO Y SALDO")
            print("El pasaje individual para esta ruta es de: S/ \(String(format: "%.2f", costoRequerido))")
            print("¿Con cuánto saldo en tu tarjeta o dinero disponible cuentas? (S/):")
            
            if let entradaSaldo = readLine(), let saldoActual = Double(entradaSaldo) {
                if saldoActual >= costoRequerido {
                    let restante = saldoActual - costoRequerido
                    print("\n✅ ¡SALDO SUFICIENTE!")
                    print("Puedes realizar tu viaje. Tu saldo restante en tarjeta será: S/ \(String(format: "%.2f", restante))")
                } else {
                    let faltante = costoRequerido - saldoActual
                    print("\n⚠️ SALDO INSUFICIENTE PARA EL VIAJE")
                    print("Tienes: S/ \(String(format: "%.2f", saldoActual)) | Necesitas: S/ \(String(format: "%.2f", costoRequerido))")
                    print(" Te faltan S/ \(String(format: "%.2f", faltante)) en tu tarjeta. Debes recargar antes de ingresar al torniquete.")
                }
            } else {
                print("❌ Monto ingresado no válido.")
            }
        }
        
    case "4":
        redCentral.desplegarTransbordos()
        
    case "5":
        print("\n--- CRITERIOS DE FILTRADO ---")
        print("1. Ver solo estaciones en funcionamiento (F)")
        print("2. Ver estaciones en proyecto/obras (NF)")
        print("3. Ver estaciones con acceso para discapacidad (♿)")
        print("Elija una opción:")
        
        let subOp = readLine() ?? ""
        switch subOp {
        case "1":
            let ops = redCentral.obtenerPorEstado(.operativo)
            print("\n=== ESTACIONES EN FUNCIONAMIENTO (\(ops.count)) ===")
            ops.forEach { print("  • [\($0.lineaPertenencia)] \($0.nombre) — \($0.cruceAvenidas)") }
        case "2":
            let noOps = redCentral.obtenerPorEstado(.fueraDeServicio)
            print("\n=== ESTACIONES EN PROYECTO / OBRAS (\(noOps.count)) ===")
            noOps.forEach { print("  • [\($0.lineaPertenencia)] \($0.nombre) — \($0.cruceAvenidas)") }
        case "3":
            let adaptadas = redCentral.obtenerConAccesoElevador()
            print("\n=== ACCESO ADAPTADO PARA DISCAPACIDAD (\(adaptadas.count)) ===")
            adaptadas.forEach { print("  • [\($0.lineaPertenencia)] \($0.nombre) ♿ — \($0.cruceAvenidas)") }
        default:
            print("❌ Opción de filtro no válida.")
        }
        
    case "6":
        imprimirLeyendaSistema()
        
    case "7":
        sistemaActivo = false
        print("\nCerrando el sistema de transporte. ¡Éxitos en la presentación, Rony!")
        
    default:
        print("❌ Opción inválida. Intente de nuevo.")
    }
}
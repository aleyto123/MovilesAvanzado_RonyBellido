// ============================================================================
// DESARROLLADO POR: Rony Bellido
// DOCENTE: Juan Leon - Tecsup
// PROYECTO: Sistema de Red Metropolitana de Transporte (POO / Structs)
// ============================================================================

import Foundation

// 1. ESTADO DE OPERATIVIDAD (Enum con valores calculados)
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
        case .fueraDeServicio: return "En Proyecto / Construcción"
        }
    }
}

// 2. MODELO DE ESTACIÓN (Struct inmutable)
struct EstacionRed {
    let identificador: String
    let nombre: String
    let lineaPertenencia: String
    let posicion: Int
    let estado: EstadoServicio
    let accesoDiscapacidad: Bool
    
    func obtenerFicha() -> String {
        let etiquetaCodigo = identificador.isEmpty ? "" : "[\(identificador)] "
        return "\(etiquetaCodigo)\(nombre) - \(estado.indicador)"
    }
}

// 3. MODELO DE LÍNEA
struct LineaTransporte {
    let denominacion: String
    let colorIdentificador: String
    var paraderos: [EstacionRed] = []
    
    func imprimirCatalogo() {
        print("\n==========================================")
        print("RED: \(denominacion.uppercased()) (Color: \(colorIdentificador))")
        print("==========================================")
        for p in paraderos {
            print("  \(p.posicion). \(p.obtenerFicha())")
        }
        print("Total de paraderos: \(paraderos.count)")
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
}

// 5. GESTOR CENTRAL DE LA RED DE TRANSPORTE
class GestorRedTransporte {
    var lineasRed: [LineaTransporte] = []
    var listaTransbordos: [TransbordoRed] = []
    
    func registrarLinea(_ linea: LineaTransporte) {
        lineasRed.append(linea)
    }
    
    func registrarTransbordo(_ transbordo: TransbordoRed) {
        listaTransbordos.append(transbordo)
    }
    
    // Obtener la totalidad de paraderos mediante programación funcional
    var todasLasEstaciones: [EstacionRed] {
        return lineasRed.flatMap { $0.paraderos }
    }
    
    // Búsqueda por filtro de coincidencia parcial de texto
    func consultarParadero(_ patron: String) -> [EstacionRed] {
        return todasLasEstaciones.filter { 
            $0.nombre.lowercased().contains(patron.lowercased()) 
        }
    }
    
    // Filtros especializados usando métodos de orden superior (.filter)
    func obtenerPorEstado(_ estadoBuscado: EstadoServicio) -> [EstacionRed] {
        return todasLasEstaciones.filter { $0.estado == estadoBuscado }
    }
    
    func obtenerConAccesoElevador() -> [EstacionRed] {
        return todasLasEstaciones.filter { $0.accesoDiscapacidad }
    }
    
    func desplegarTransbordos() {
        print("\n--- PUNTOS DE INTERCAMBIO Y TRANSBORDO ---")
        for t in listaTransbordos {
            print("🔗 \(t.origenLinea) (\(t.origenEstacion)) <--> \(t.destinoLinea) (\(t.destinoEstacion))")
            print("   Modalidad: \(t.modalidad)")
            print("   Ubicación: \(t.referenciaUbicacion)\n")
        }
    }
}

// MUESTRA DE LEYENDA TÉCNICA
func imprimirLeyendaSistema() {
    print("\n==========================================")
    print("📖 LEYENDA DE SIMBOLOGÍA TÉCNICA")
    print("==========================================")
    print(" (F)  : Estación Operativa (En Funcionamiento)")
    print(" (NF) : Estación No Operativa (Fuera de Servicio / Obras)")
    print(" [E-XX]: Código de infraestructura asignado")
    print(" 🔗   : Nodo de transbordo entre redes")
    print("==========================================\n")
}

// ============================================================================
// CARGA Y CONFIGURACIÓN DE DATOS (Rony Bellido)
// ============================================================================
let redCentral = GestorRedTransporte()

// LÍNEA 1
var l1 = LineaTransporte(denominacion: "Linea 1", colorIdentificador: "Verde")
let paraderosL1 = ["Villa El Salvador", "Parque Industrial", "Pumacahua", "Villa Maria",
                   "Maria Auxiliadora", "San Juan", "Atocongo", "Jorge Chavez", "Ayacucho",
                   "Cabitos", "Angamos", "San Borja Sur", "La Cultura", "Arriola", "Gamarra",
                   "Miguel Grau", "El Angel", "Presbitero Maestro", "Caja de Agua",
                   "Piramide del Sol", "Los Jardines", "Los Postes", "San Carlos",
                   "San Martin", "Santa Rosa", "Bayovar"]

for (idx, nom) in paraderosL1.enumerated() {
    l1.paraderos.append(EstacionRed(identificador: "", nombre: nom, lineaPertenencia: "Linea 1", posicion: idx + 1, estado: .operativo, accesoDiscapacidad: true))
}
redCentral.registrarLinea(l1)

// LÍNEA 2
var l2 = LineaTransporte(denominacion: "Linea 2", colorIdentificador: "Amarillo")
let paraderosL2 = ["Puerto del Callao", "Buenos Aires", "Juan Pablo II", "Insurgentes",
                   "Carmen de la Legua", "Oscar R. Benavides", "San Marcos", "Elio",
                   "La Alborada", "Tingo Maria", "Parque Murillo", "Plaza Bolognesi",
                   "Estacion Central", "Manco Capac", "Cangallo", "28 de Julio",
                   "Nicolas Ayllon", "Circunvalacion", "San Juan de Dios", "Evitamiento",
                   "Ovalo Santa Anita", "Colectora Industrial", "Hermilio Valdizan",
                   "Mercado Santa Anita", "Vista Alegre", "Prolongacion Javier Prado",
                   "Municipalidad de Ate"]

for (idx, nom) in paraderosL2.enumerated() {
    let num = idx + 1
    let cod = String(format: "E-%02d", num)
    let activa = (num >= 20 && num <= 24)
    l2.paraderos.append(EstacionRed(identificador: cod, nombre: nom, lineaPertenencia: "Linea 2", posicion: num, estado: activa ? .operativo : .fueraDeServicio, accesoDiscapacidad: activa))
}
redCentral.registrarLinea(l2)

// LÍNEA 3
var l3 = LineaTransporte(denominacion: "Linea 3", colorIdentificador: "Celeste")
let paraderosL3 = ["Pedro Miotta", "Los Heroes", "Las Gardenias", "Alejandro Velasco",
                   "Cabitos", "Juana Alarco", "Republica de Panama", "Parque Reducto",
                   "Parque Central de Miraflores", "Huaca Pucllana", "Andres Aramburu",
                   "Conde de San Isidro", "Cesar Canevaro", "Museo de Historia Natural",
                   "Parque de la Reserva", "Estacion Central", "Garcilaso de la Vega",
                   "Tacna", "Caqueta", "Jose Granda", "Bartolome de las Casas",
                   "Tomas Valle", "Carlos Izaguirre", "Naranjal", "Villa Sol",
                   "2 de Octubre", "Huandoy", "El Alamo"]

for (idx, nom) in paraderosL3.enumerated() {
    l3.paraderos.append(EstacionRed(identificador: "", nombre: nom, lineaPertenencia: "Linea 3", posicion: idx + 1, estado: .fueraDeServicio, accesoDiscapacidad: false))
}
redCentral.registrarLinea(l3)

// LÍNEA 4
var l4 = LineaTransporte(denominacion: "Linea 4", colorIdentificador: "Rojo")
let paraderosL4 = ["Venezuela", "Rafael Escardo", "Pando", "Jose de Sucre", "Brasil",
                   "Felipe Salaverry", "Guillermo Prescott", "Las Palmeras",
                   "Conde de San Isidro", "Rivera Navarrete", "Pablo Carriquiry",
                   "La Cultura", "San Luis", "Monterrico", "Manuel Olguin", "Los Frutales",
                   "La Molina", "Santa Patricia", "Mayorazgo", "Mercado Santa Anita"]

for (idx, nom) in paraderosL4.enumerated() {
    l4.paraderos.append(EstacionRed(identificador: "", nombre: nom, lineaPertenencia: "Linea 4", posicion: idx + 1, estado: .fueraDeServicio, accesoDiscapacidad: false))
}
redCentral.registrarLinea(l4)

// REGISTRO DE PUNTOS DE INTERCAMBIO
redCentral.registrarTransbordo(TransbordoRed(origenLinea: "Linea 1", origenEstacion: "Gamarra", destinoLinea: "Linea 2", destinoEstacion: "28 de Julio", modalidad: "Conexión peatonal urbana (500m)", referenciaUbicacion: "Av. Aviación con Av. 28 de Julio"))
redCentral.registrarTransbordo(TransbordoRed(origenLinea: "Linea 1", origenEstacion: "La Cultura", destinoLinea: "Linea 4", destinoEstacion: "La Cultura", modalidad: "Estación de intercambio subterráneo", referenciaUbicacion: "Av. Javier Prado con Av. Aviación"))
redCentral.registrarTransbordo(TransbordoRed(origenLinea: "Linea 2", origenEstacion: "Estacion Central", destinoLinea: "Linea 3", destinoEstacion: "Estacion Central", modalidad: "Hub Central Intermodal", referenciaUbicacion: "Paseo Colón / Plaza Grau"))

// ============================================================================
// BUCLE INTERACTIVO DE CONSOLA
// ============================================================================
var ejecucionActiva = true

while ejecucionActiva {
    print("\n------------------------------------------")
    print("   SISTEMA METROPOLITANO DE TRANSPORTE")
    print("          Usuario: Rony Bellido")
    print("------------------------------------------")
    print("1. Consultar estaciones por línea")
    print("2. Buscar estación por nombre")
    print("3. Ver puntos de transbordo")
    print("4. Filtrar paraderos (Estado / Accesibilidad)")
    print("5. Ver Leyenda de Simbología")
    print("6. Salir")
    print("Seleccione una opción:")
    
    let entrada = readLine() ?? ""
    
    switch entrada {
    case "1":
        print("\nIngrese el número de línea a consultar (1 - 4):")
        if let num = Int(readLine() ?? ""), num >= 1 && num <= 4 {
            redCentral.lineasRed[num - 1].imprimirCatalogo()
        } else {
            print("❌ Selección fuera de rango.")
        }
        
    case "2":
        print("\nIngrese el nombre o fragmento a buscar:")
        let termino = readLine() ?? ""
        let hallados = redCentral.consultarParadero(termino)
        
        if hallados.isEmpty {
            print("❌ No se registraron coincidencias.")
        } else {
            print("\n--- RESULTADOS ENCONTRADOS (\(hallados.count)) ---")
            for e in hallados {
                print("📍 \(e.lineaPertenencia): \(e.obtenerFicha()) | Estado: \(e.estado.descripcion)")
            }
        }
        
    case "3":
        redCentral.desplegarTransbordos()
        
    case "4":
        print("\n--- MENÚ DE FILTRADO ---")
        print("1. Estaciones Operativas (F)")
        print("2. Estaciones Fuera de Servicio / Obras (NF)")
        print("3. Estaciones con Acceso Adaptado")
        print("Elija el filtro:")
        
        let subOpcion = readLine() ?? ""
        switch subOpcion {
        case "1":
            let ops = redCentral.obtenerPorEstado(.operativo)
            print("\n=== ESTACIONES OPERATIVAS (\(ops.count)) ===")
            ops.forEach { print("  • \($0.lineaPertenencia): \($0.nombre)") }
        case "2":
            let noOps = redCentral.obtenerPorEstado(.fueraDeServicio)
            print("\n=== ESTACIONES EN PROYECTO / OBRAS (\(noOps.count)) ===")
            noOps.forEach { print("  • \($0.lineaPertenencia): \($0.nombre)") }
        case "3":
            let adaptadas = redCentral.obtenerConAccesoElevador()
            print("\n=== ACCESO ADAPTADO CONFIRMADO (\(adaptadas.count)) ===")
            adaptadas.forEach { print("  • \($0.lineaPertenencia): \($0.nombre)") }
        default:
            print("❌ Criterio no válido.")
        }
        
    case "5":
        imprimirLeyendaSistema()
        
    case "6":
        ejecucionActiva = false
        print("\nCerrando sesión del sistema. ¡Hasta luego, Rony!")
        
    default:
        print("❌ Opción inválida. Intente de nuevo.")
    }
}
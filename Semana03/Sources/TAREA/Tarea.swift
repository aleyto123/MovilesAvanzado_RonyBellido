// Desarrollado por: Rony Bellido
import Foundation

let estaciones: [String: (linea: String, conexiones: [String], cruce: String, lugares: [String])] = [
    "Grau": ("Línea 1", ["Conexión proyectada Línea 5", "Corredor Morado", "Buses tradicionales"], "Av. Grau con Av. Aviación", ["Hospital Almenara"]),
    "Central": ("Metropolitano", ["Corredor Azul", "Línea 2 (Estación Central)"], "Paseo de la República con Av. Bolivia", ["Estadio Nacional", "Centro Cívico", "Plaza San Martín"]),
    "Cultura": ("Línea 1", ["Corredor Rojo 201", "Corredor Rojo 209"], "Av. Javier Prado con Av. Aviación", ["Teatro Nacional", "Museo de la Nación", "Av. Canevaro (Ruta cercana)"]),
    "Canevaro": ("Línea 2", ["Buses ruta troncal", "Corredor Morado"], "Av. Canevaro con Av. Arenales", ["Hospital Rebagliati"])
]

var salir = false

while !salir {
    print("\n=== SISTEMA DE CONEXIONES Y RUTAS ===")
    print("1) Buscar información de una estación")
    print("2) Buscar cómo llegar a un lugar (ej. Estadio Nacional)")
    print("3) Salir")
    print("Elige una opción:")
    
    let opcion = readLine() ?? ""
    
    switch opcion {
    case "1":
        print("\nIngrese el nombre de la estación (ej. Grau, Central, Cultura):")
        let busqueda = readLine() ?? ""
        let claveBuscada = busqueda.capitalized
        
        if let info = estaciones[claveBuscada] {
            print("\n📍 ESTACIÓN \(claveBuscada.uppercased()) (\(info.linea))")
            print("🗺️ Ubicación: \(info.cruce)")
            print("🔄 Conexiones disponibles: \(info.conexiones.joined(separator: ", "))")
            print("🏢 Lugares cercanos: \(info.lugares.joined(separator: ", "))")
        } else {
            print("❌ Estación no encontrada en la red.")
        }
    default:
        break
    }
}
// Desarrollado por: Rony Bellido
import Foundation

// Base de datos estructurada usando un Diccionario con Tuplas
let estaciones: [String: (linea: String, conexiones: [String], cruce: String, lugares: [String])] = [
    "Grau": ("Línea 1", ["Conexión proyectada Línea 5", "Corredor Morado", "Buses tradicionales"], "Av. Grau con Av. Aviación", ["Hospital Almenara"]),
    "Central": ("Metropolitano", ["Corredor Azul", "Línea 2 (Estación Central)"], "Paseo de la República con Av. Bolivia", ["Estadio Nacional", "Centro Cívico", "Plaza San Martín"]),
    "Cultura": ("Línea 1", ["Corredor Rojo 201", "Corredor Rojo 209"], "Av. Javier Prado con Av. Aviación", ["Teatro Nacional", "Museo de la Nación", "Av. Canevaro (Ruta cercana)"]),
    "Canevaro": ("Línea 2", ["Buses ruta troncal", "Corredor Morado"], "Av. Canevaro con Av. Arenales", ["Hospital Rebagliati"])
]
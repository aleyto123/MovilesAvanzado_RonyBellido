// Desarrollado por: Rony Bellido
import Foundation // Importa la librería base de Swift

print("¿Cuántos alumnos registrará?") // Pide al usuario la cantidad de alumnos
let n = Int(readLine() ?? "") ?? 0 // Lee la entrada y la convierte a entero
var notasDict: [String: [Double]] = [:] // Crea un diccionario vacío para los alumnos y sus notas

if n > 0 { // Verifica que la cantidad sea mayor a cero
    for i in 1...n { // Bucle para iterar por cada alumno
        print("Nombre del alumno \(i):") // Pide el nombre del alumno
        let nombre = readLine() ?? "" // Guarda el nombre ingresado
        var notasArray: [Double] = [] // Crea un arreglo vacío para las 3 notas
        for j in 1...3 { // Bucle para pedir 3 notas por alumno
            print("Nota \(j):") // Pide la nota específica
            let nota = Double(readLine() ?? "") ?? 0 // Convierte la nota a Double
            notasArray.append(nota) // Agrega la nota al arreglo temporal
        } // Fin del bucle de notas
        notasDict[nombre] = notasArray // Guarda el arreglo en el diccionario usando el nombre como clave
    } // Fin del bucle de alumnos
} // Fin de la validación inicial

var sumaGeneral = 0.0 // Variable para sumar todos los promedios
var aprobados = 0 // Contador de alumnos aprobados
var maxNota = 0.0 // Variable para guardar la nota máxima
var minNota = 20.0 // Variable para guardar la nota mínima, inicializada alta

print("\n--- REPORTE ---") // Imprime cabecera del reporte
for (alumno, notas) in notasDict { // Recorre el diccionario de alumnos
    var sumaNotas = 0.0 // Inicializa la suma de notas del alumno
    for nota in notas { // Recorre las notas del alumno
        sumaNotas += nota // Suma cada nota
    } // Fin de suma de notas
    let promedio = sumaNotas / Double(notas.count) // Calcula el promedio del alumno
    sumaGeneral += promedio // Suma el promedio a la suma general del salón
    
    if promedio > maxNota { maxNota = promedio } // Actualiza la nota máxima si aplica
    if promedio < minNota { minNota = promedio } // Actualiza la nota mínima si aplica
    
    var clasificacion = "" // Variable para el estado del alumno
    switch promedio { // Evalúa el promedio
    case 18...20: clasificacion = "Excelente" // Asigna Excelente
    case 15..<18: clasificacion = "Bueno" // Asigna Bueno
    case 13..<15: clasificacion = "Aprobado" // Asigna Aprobado
    default: clasificacion = "Desaprobado" // Asigna Desaprobado
    } // Fin del switch
    
    if promedio >= 13 { aprobados += 1 } // Aumenta el contador si aprobó
    print("\(alumno): Promedio = \(promedio) (\(clasificacion))") // Imprime el resultado
} // Fin del recorrido

if notasDict.count > 0 { // Verifica que haya alumnos para evitar división por cero
    let promGlobal = sumaGeneral / Double(notasDict.count) // Calcula el promedio global
    let pct = (Double(aprobados) / Double(notasDict.count)) * 100 // Calcula el % de aprobados
    print("\n--- ESTADÍSTICAS ---") // Cabecera de estadísticas
    print("Promedio general: \(promGlobal)") // Imprime promedio general
    print("Nota más alta: \(maxNota)") // Imprime nota más alta
    print("Nota más baja: \(minNota)") // Imprime nota más baja
    print("% de aprobados: \(pct)%") // Imprime el porcentaje de aprobados
} // Fin de impresión
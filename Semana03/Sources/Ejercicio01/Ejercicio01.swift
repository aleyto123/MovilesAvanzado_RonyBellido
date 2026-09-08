// Desarrollado por: Rony Bellido
import Foundation

// TODO 1: Registro de 5 alumnos
var alumnos: [String] = []
for i in 1...5 {
    print("Nombre del alumno \(i):")
    let nombre = readLine() ?? ""
    alumnos.append(nombre)
}
print("Alumnos: \(alumnos)")

// TODO 2: Buscar un alumno
print("Buscar alumno:")
let buscar = readLine() ?? ""
if alumnos.contains(buscar) {
    print("\(buscar) está en la lista")
} else {
    print("\(buscar) NO está en la lista")
}

// TODO 3: Notas con clasificación
var notasClase: [Double] = []
for i in 1...5 {
    print("Nota del alumno \(i):")
    let n = Double(readLine() ?? "") ?? 0
    notasClase.append(n)
}
var aprobados = 0
var desaprobados = 0
var sumaNotas = 0.0
for nota in notasClase {
    sumaNotas += nota
    if nota >= 13 { 
        aprobados += 1
    } else {
        desaprobados += 1
    }
}
print("Promedio: \(sumaNotas / Double(notasClase.count))")
print("Aprobados: \(aprobados), Desaprobados: \(desaprobados)")

// FIX: 3 errores =====
var frutas = ["Manzana", "Plátano", "Naranja"]
frutas.append("Pera") // FIX 1: Era un Int (7), debe ser un String

var colores = ["Rojo", "Azul", "Verde"] // FIX 2: Era let, debe ser var para poder mutar
colores.append("Amarillo")

let numeros = [10, 20, 30, 40, 50]
print(numeros[4]) // FIX 3: El índice 5 está fuera de rango, el máximo es 4

// PREDICT
var lista = [1,2,3,4,5]
lista.remove(at: 0)
lista.append(6)
print(lista)       // PREDICT 1: [2, 3, 4, 5, 6]
print(lista.count) // PREDICT 2: 5

var nombres = ["Ana", "Carlos", "Beto"]
print(nombres.sorted()) // PREDICT 3: ["Ana", "Beto", "Carlos"]
print(nombres)          // PREDICT 4: ["Ana", "Carlos", "Beto"]
// Desarrollado por: Rony Bellido
import Foundation

// TODO 8: Eliminar duplicados
var numerosArr: [Int] = []
for i in 1...8 {
    print("Numero \(i):")
    let n = Int(readLine() ?? "") ?? 0
    numerosArr.append(n)
}
print("Con duplicados: \(numerosArr)")
let sinDuplicados = Array(Set(numerosArr)).sorted()
print("Sin duplicados: \(sinDuplicados)")

// TODO 9: Comparar asistencia
var lunes: Set<String> = []
var martes: Set<String> = []

print("\n--- ASISTENCIA LUNES ---")
for i in 1...4 {
    print("Nombre \(i):")
    lunes.insert(readLine() ?? "")
}
print("\n--- ASISTENCIA MARTES ---")
for i in 1...4 {
    print("Nombre \(i):")
    martes.insert(readLine() ?? "")
}

print("Asistieron ambos días: \(lunes.intersection(martes))")
print("Asistieron solo lunes: \(lunes.subtracting(martes))")
print("Asistieron solo martes: \(martes.subtracting(lunes))")

// PREDICT
let a: Set = [1,2,3,4,5]
let b: Set = [4,5,6,7,8]
print(a.intersection(b)) // PREDICT 5: [4, 5] (sin orden garantizado)
print(a.union(b).count)  // PREDICT 6: 8
print(a.subtracting(b))  // PREDICT 7: [1, 2, 3] (sin orden garantizado)

var repetidos: Set = ["A", "B", "A", "C", "B"]
print(repetidos.count)   // PREDICT 8: 3
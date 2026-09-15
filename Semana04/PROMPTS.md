# Prompts utilizados – Laboratorio 04

## Herramienta de IA utilizada
Gemini

## Caso 2B – Biblioteca

### Prompt 1:
"Soy estudiante de Swift, cuarta semana, trabajo en un Playground de Xcode. Necesito una biblioteca con enum EstadoLibro, struct Libro y class Biblioteca con prestar, devolver e inventario. Solo struct, class, herencia, protocolos, enums, arrays, bucles por índice y funciones. Sin optionals ni guard let, sin firstIndex(where:), sin didSet, sin propiedades calculadas, sin genéricos. Agrega un comentario en CADA línea explicando qué hace."

### Respuesta de la IA:
Generó la estructura con el enum `EstadoLibro`, la struct `Libro` con estado por defecto, y la clase `Biblioteca` que gestiona el arreglo usando bucles `for i in 0..<libros.count` para mutar el estado directamente en el arreglo, incluyendo comentarios explicativos en las líneas de código.

### ¿Funcionó a la primera?
Sí, generó el código Swift respetando las firmas y las restricciones de no usar `firstIndex`, `guard let` ni `optionals`.

### ¿Usó algo que no hemos visto en clase?
No, utilizó exclusivamente `struct`, `class`, `enum`, arreglos, bucles por índice y `switch`.

## Mi versión (Parte A) vs. la versión de la IA (Parte B)

### ¿Qué hizo distinto la IA respecto a mi solución?
La IA incluyó comentarios explicativos en las líneas clave para justificar por qué se debe mutar el `struct` accediendo directamente al índice del arreglo (`libros[i]`).

### ¿Hay alguna línea de la IA que no entiendo del todo? ¿Cuál?
No, todas las líneas utilizan sintaxis básica de Swift explicada durante las primeras cuatro semanas.

### ¿Qué me pareció mejor de MI versión?
Que la versión manual era más limpia al no tener comentarios en cada línea de código.

### ¿Qué me pareció mejor de la versión de la IA?
La precisión para explicar por qué se debe modificar el `struct` directamente dentro del arreglo por índice en vez de asignarlo a una variable local.
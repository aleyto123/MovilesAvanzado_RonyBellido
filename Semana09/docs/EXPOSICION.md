# Guía de exposición para dos participantes

## Participante 1 — Cálculo y Excel

1. Abrir `Boleta_Grupo_B.xlsx` y presentar las cuatro hojas.
2. Mostrar `Parámetros`: RMV, ONP, EsSalud y diccionario de tasas AFP. Diferenciar AFP Ejemplo de tasas SBS sobre flujo.
3. En `Casos`, recorrer el caso 3: sueldo 3,000, asignación 123, horas extras 62.50 y 67.50. Explicar por qué se redondea cada concepto y no el valor hora intermedio.
4. Seleccionar el caso 3 en `Boleta!B3`. Explicar los tres bloques y el neto S/ 2,631.73. Mostrar la fórmula de una celda en la barra de fórmulas o activar Fórmulas > Mostrar fórmulas.
5. Mostrar el caso 4 y su neto S/ 3,011.17. Comparar las columnas de diferencias con Swift.
6. Presentar las respuestas de `Explicación` y el caso propio. Precisar que los datos de los compañeros deben venir de ellos.

## Participante 2 — App y código SwiftUI

1. Abrir `BoletaPago.xcodeproj` en la Mac y ejecutar el esquema BoletaPago en un iPhone simulado.
2. Presentar la pantalla única: formulario, botón Calcular y boleta debajo, dentro de ScrollView.
3. Ejecutar el caso 1: neto 2,175.00. Cambiar a AFP: aparece el selector AFP. Ejecutar el caso 4 y compararlo con el Excel.
4. Mostrar un error: días 31, sueldo vacío o un monto con texto. Explicar que no queda una boleta anterior como si fuera válida.
5. Abrir `Modelos.swift`: structs, array de conceptos y diccionario de AFP. Abrir `Boleta.swift`: clase calculadora independiente de la interfaz.
6. Abrir `ContentView.swift`: @State mantiene entradas y resultados, y el botón invoca validación y cálculo.
7. Ejecutar `swift test`. Explicar las cinco pruebas: cuatro casos al centavo, redondeo, entradas inválidas, EsSalud y AFP. Mostrar el reporte de 70 importes coincidentes.

## Preguntas que ambos deben poder responder

- ¿Por qué EsSalud no está en los descuentos? Lo paga el empleador.
- ¿Por qué la asignación no baja en el caso 2? La actividad dispone pagar el 10% de la RMV completo.
- ¿Por qué no se usa Double? Decimal evita errores binarios en importes monetarios.
- ¿El adelanto reduce el ingreso total del trabajador? Reduce el pago pendiente, porque ya recibió ese dinero.
- ¿Qué no prueba el control cruzado? La ejecución visual de SwiftUI; se comprueba en el simulador.

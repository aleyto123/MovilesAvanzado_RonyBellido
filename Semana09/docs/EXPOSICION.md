# Guía de exposición para dos participantes

Distribución propuesta para los 10 minutos disponibles: 5 minutos de Excel, 4 minutos de app y 1 minuto de margen. Es una propuesta de organización; las preguntas del documento se transcriben al final.

## Participante 1 — Cálculo y Excel

1. **1 minuto:** abrir `outputs/semana09/Boleta_Grupo_B.xlsx`, nombrar sus cuatro hojas y mostrar los parámetros centralizados.
2. **3 minutos:** en el índice de `Explicación`, abrir **Caso 3**. Explicar el sueldo y la asignación; luego las horas extras; después AFP, adelanto y neto. Cada fila muestra la fórmula de Excel, su explicación y un ejemplo numérico. El neto es S/ 2,631.73.
3. **1 minuto:** mostrar en `Casos` que están los cuatro casos y sus diferencias frente al motor Swift. Señalar el caso 4, con neto S/ 3,011.17, y ubicar las respuestas de análisis y el caso con sueldo de una oferta real.

## Participante 2 — App y código SwiftUI

1. **1 minuto:** abrir una ejecución completada de **Semana09 - Simulador iPhone** en GitHub Actions y mostrar la captura del formulario o la grabación. Presentar la pantalla única: formulario, botón Calcular y boleta debajo, dentro de `ScrollView`.
2. **1 minuto:** mostrar la evidencia del caso 3 y comparar su neto S/ 2,631.73 con Excel. Mostrar la captura de validación de 31 días y comprobar que desaparece el resultado anterior.
3. **2 minutos:** abrir `Sources/BoletaCore/Modelos.swift` para señalar las estructuras y las tasas AFP; `Sources/BoletaCore/Boleta.swift` para mostrar el cálculo separado de la pantalla; y `App/ContentView.swift` para mostrar las entradas con `@State` y el botón. Cerrar con el resultado de las pruebas de Actions.

Preparar las capturas o el fragmento de video antes de exponer. El workflow tarda en compilar y probar: no iniciarlo durante los cuatro minutos de la demostración. Consultar [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) para descargar las evidencias. Si se dispone de una Mac, también se puede mostrar la app directamente abriendo `BoletaPago.xcodeproj`.

## Preguntas de análisis del documento del profesor

Fuente: `Actividad_Grupo_B.docx`, sección 8, «Preguntas de análisis». Se transcriben las cinco consignas de esa sección. El documento no indica que sean preguntas de un interrogatorio oral.

1. **ONP o AFP.** Con los datos del caso 3, calcula el neto con ONP y con AFP Ejemplo. ¿Cuál deja más dinero este mes? ¿Por qué no basta comparar los porcentajes para decidir cuál conviene al trabajador?
2. **Costo real para la empresa.** En el caso 3, ¿cuánto cuesta el trabajador al empleador este mes (remuneraciones más EsSalud)? ¿Qué porcentaje de ese costo llega al trabajador como neto?
3. **Días laborados.** Con los datos del caso 2, calcula el neto si el trabajador hubiera laborado los 30 días. ¿Por qué la diferencia en el neto es menor que la diferencia en el sueldo bruto?
4. **Horas extras.** En el caso 3, ¿qué porcentaje del total de remuneraciones representan las horas extras?
5. **Con datos reales.** Toma un sueldo de una oferta laboral publicada, arma su boleta y calcula qué porcentaje del sueldo bruto llega al trabajador. Compara tu resultado con el de dos compañeros que usaron otros sueldos.

Las respuestas desarrolladas están en [ANALISIS.md](ANALISIS.md).

# CTS Perú

Trabajo individual de la semana 08. Se desarrollarán dos entregables: una aplicación SwiftUI que automatice los cálculos del alcance definido y un Excel que permita explicarlos, comprobarlos y vincularlos con las normas peruanas.

La aclaración dada en clase convierte al Excel en un entregable propio. Ya no se espera encontrar una plantilla dentro del laboratorio Word.

## Plan de seis commits

| Commit | Contenido | Estado |
| --- | --- | --- |
| 1 | Formulario inicial de CTS y definición del trabajo individual | Realizado |
| 2 | Base legal detallada y Excel con fórmulas y ejemplos de referencia | Pendiente |
| 3 | Motor de cálculo de CTS y gratificación, periodos y pruebas en Swift | Pendiente |
| 4 | Formularios SwiftUI conectados al motor y explicación de resultados | Pendiente |
| 5 | Vacaciones gozadas, ausencias y escenarios proporcionales en app y Excel | Pendiente |
| 6 | Comparación final entre cálculo manual, Excel y app; guía para sustentar | Pendiente |

El contenido y los criterios para cerrar cada avance están en [el plan de desarrollo](PLAN_DESARROLLO.md). Las fuentes consultadas y las primeras distinciones legales están en [la base legal inicial](BASE_LEGAL.md).

## Estado actual

Solo está terminado el commit 1. La app muestra los campos de sueldo, gratificación y meses. Los cálculos, la automatización de fechas y el archivo Excel se construirán en los siguientes avances.

El formulario inicial sirve para aprender `VStack`, `Text`, `TextField`, `@State` y los enlaces con `$`. Se ampliará a partir de los casos comprobados en Excel.

## Alcance de referencia

Se parte del régimen laboral general de la actividad privada, para un trabajador con remuneración mensual fija. Se explicarán la CTS, la gratificación y el efecto de las vacaciones remuneradas y de las ausencias. Las reglas, requisitos y límites se harán visibles en ambos entregables.

## Abrir el proyecto

Abrir `Tarea_CTS.xcodeproj`, seleccionar un simulador de iPhone y ejecutar con Run. El código del primer avance está en `Tarea_CTS/ContentView.swift`.

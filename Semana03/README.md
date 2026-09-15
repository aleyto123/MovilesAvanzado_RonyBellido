# Requerimientos del Sistema de Gestión de Transporte Metropolitano y Tarifario

**Estudiante:** Rony Bellido  
**Curso:** Programación Móvil Avanzada  
**Docente:** Juan León  
**Institución:** Tecsup  

---

## 1. Objetivo del Proyecto
Desarrollar un sistema interactivo en Swift basado en consola que permita consultar la red de transporte público (Línea 1 y Línea 2 del Metro de Lima), planificar rutas hacia puntos de interés, calcular el costo de los pasajes y verificar el saldo disponible en la tarjeta de transporte del usuario.

---

## 2. Requerimientos Funcionales

### RF-01: Catálogo de Estaciones y Tarifas por Línea
- El sistema debe almacenar la información completa de las estaciones de la Línea 1 y Línea 2.
- Cada línea debe registrar su estructura tarifaria:
  - **Línea 1:** Pasaje Adulto S/ 1.50 | Medio Pasaje S/ 0.75.
  - **Línea 2:** Pasaje Adulto S/ 1.40 | Medio Pasaje S/ 0.70.
- Cada estación debe contener:
  - Nombre oficial e identificador correlativo (`[E-XX]`).
  - Posición dentro de la red.
  - Ubicación exacta por cruce de avenidas.
  - Lista de puntos de interés y lugares cercanos.
  - Estado de operabilidad (`(F)` / `(NF)`).
  - Indicador de acceso adaptado para discapacidad (`♿`).
  - Frecuencia aproximada de paso de trenes (en minutos).

### RF-02: Consulta de Ficha Técnica con Costo
- Permitir la búsqueda de estaciones por coincidencia de nombre.
- Desplegar una ficha técnica con la ubicación, accesibilidad, frecuencia y el costo del pasaje asignado a la línea.

### RF-03: Planificador de Ruta ("¿Cómo llegar a un lugar?")
- Permitir búsquedas inversas introduciendo un destino o hito urbano (ej. *Estadio Nacional*, *Gamarra*, *Minka*, *Mall del Sur*).
- Retornar la estación de descenso sugerida, el cruce de avenidas y el precio del pasaje (General y Universitario/Escolar).

### RF-04: Verificación de Presupuesto y Saldo en Tarjeta
- Una vez calculada la ruta sugerida, el sistema debe solicitar al usuario ingresar el saldo actual de su tarjeta o dinero disponible (en S/).
- Evaluar la viabilidad financiera del viaje:
  - **Saldo suficiente:** Mostrar mensaje de confirmación y calcular el saldo restante tras descontar el pasaje.
  - **Saldo insuficiente:** Mostrar mensaje de advertencia indicando el saldo actual, el monto requerido y la diferencia exacta que le falta recargar.

### RF-05: Módulo de Transbordos e Intercambios
- Mostrar los puntos de conexión entre líneas (ej. Gamarra - 28 de Julio, Estación Central).
- Detallar la modalidad de transferencia, referencia de ubicación y el tiempo estimado de caminata en minutos.

### RF-06: Filtros de Red
- Permitir la filtración del catálogo total según:
  - Estaciones en funcionamiento `(F)`.
  - Estaciones en construcción o proyecto `(NF)`.
  - Estaciones con accesibilidad garantizada para movilidad reducida `♿`.

### RF-07: Leyenda de Simbología Técnica
- Proporcionar una sección dedicada a la explicación de la nomenclatura del sistema:
  - `(F)`: Estación Operativa.
  - `(NF)`: Estación No Operativa / Obras.
  - `[E-XX]`: Código de infraestructura asignado.
  - `💳`: Saldo y tarifario de transporte.
  - `♿`: Acceso adaptado.
  - `🔗`: Nodo de transbordo entre líneas.

---

## 3. Requerimientos No Funcionales

- **Arquitectura Swift Idiomática:** Implementado en Swift utilizando `struct` para el modelado de datos inmutables, `enum` con propiedades calculadas para gestión de estado y programación funcional (`flatMap`, `filter`) para filtrado de arreglos.
- **Validación de Entradas:** Manejo seguro de conversiones de tipos (`Double`, `Int`) ante entradas nulas o erróneas en la consola.
- **Portabilidad:** Ejecución directa mediante la CLI de Swift (`swift main.swift` o `swift Tarea.swift`).
- **Control de Versiones:** Registro mediante commits descriptivos en Git.

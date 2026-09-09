# Requerimientos del Sistema de Gestión de Transporte Metropolitano

**Estudiante:** Rony Bellido  
**Curso:** Programación Móvil Avanzada  
**Institución:** Tecsup  

---

## 1. Objetivo del Proyecto
Desarrollar una aplicación en Swift basada en consola que permita gestionar, consultar y planificar rutas dentro de la red de transporte público (Línea 1 y Línea 2 del Metro de Lima). El sistema utiliza estructuras inmutables (`struct`), enumeraciones orientadas a estado (`enum`) y programación funcional para garantizar alto rendimiento y mantenibilidad.

---

## 2. Requerimientos Funcionales

### RF-01: Catálogo de Estaciones y Redes
- El sistema debe almacenar la información completa de las estaciones pertenecientes a la Línea 1 y Línea 2.
- Cada estación debe registrar:
  - Nombre oficial e identificador único (`[E-XX]`).
  - Posición ordinal en la línea.
  - Cruce de avenidas principales o ubicación geográfica.
  - Puntos de interés y lugares turísticos/comerciales cercanos.
  - Estado de operabilidad (`(F)` o `(NF)`).
  - Disponibilidad de infraestructura para discapacidad (elevadores/rampas).
  - Frecuencia estimada de llegada del servicio.

### RF-02: Búsqueda de Ficha Técnica por Estación
- Permitir al usuario buscar cualquier estación ingresando su nombre total o parcial.
- Mostrar una ficha técnica detallada que incluya ubicación, red, accesibilidad y puntos de interés.

### RF-03: Planificador de Ruta ("¿Cómo llegar a un lugar?")
- Permitir la búsqueda inversa basada en un destino urbano o hito de interés (ejemplo: *Estadio Nacional*, *Gamarra*, *Minka*, *Teatro Nacional*).
- Indicar al usuario en qué estación debe descender, la línea correspondiente y el cruce exacto de avenidas.

### RF-04: Módulo de Transbordos y Conexiones
- Registrar los puntos de intercambio intermodal entre diferentes líneas.
- Mostrar la modalidad de transbordo (peatonal asistido, subterráneo) y el tiempo estimado de caminata en minutos.

### RF-05: Filtros de Red
- Filtrar la lista total de estaciones según:
  - Estaciones operativas `(F)`.
  - Estaciones en construcción/proyecto `(NF)`.
  - Estaciones con accesibilidad garantizada `♿`.

### RF-06: Leyenda de Simbología Técnica
- Proporcionar una sección dedicada a explicar la codificación del sistema:
  - `(F)`: En Funcionamiento.
  - `(NF)`: No Operativo / En Obras.
  - `♿`: Acceso Adaptado para Movilidad Reducida.
  - `🔗`: Nodo de Transbordo.

---

## 3. Requerimientos No Funcionales

- **Arquitectura:** Diseñado bajo principios de Swift Idiomático empleando `struct` para la inmutabilidad de datos y `enum` con propiedades calculadas.
- **Consultas Eficientes:** Implementación de programación funcional (`flatMap`, `filter`) para búsquedas en tiempo de ejecución.
- **Portabilidad:** Ejecución directa mediante la CLI de Swift (`swift main.swift`) sin dependencias externas obligatorias.
- **Control de Versiones:** Historial de cambios limpio e incremental mediante Git.